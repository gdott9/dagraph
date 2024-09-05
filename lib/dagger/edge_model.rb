require 'active_support/concern'
require 'active_support/core_ext/array/access'

module Dagger
  module EdgeModel
    extend ActiveSupport::Concern

    included do
      belongs_to :entry_edge, class_name: model_name.to_s, optional: true
      belongs_to :direct_edge, class_name: model_name.to_s, optional: true
      belongs_to :exit_edge, class_name: model_name.to_s, optional: true

      belongs_to :parent, class_name: _dagger.nodes_class_name
      belongs_to :child, class_name: _dagger.nodes_class_name

      scope :direct, -> { where hops: 0 }
      scope :implicit, -> { where.not hops: 0 }

      attr_readonly :entry_edge_id, :direct_edge_id, :exit_edge_id,
        :parent_id, :child_id, :hops, :source

      after_create :add_implicit_edges!
      after_save :calculate_implicit_edges_weight!

      before_destroy :check_readonly
      before_destroy :destroy_implicit_edges!
      after_destroy :calculate_direct_edges_weight!

      validate :_dagger_cycle_detection
    end

    def direct?
      hops.zero?
    end

    def implicit?
      !direct?
    end

    def readonly?
      implicit?
    end

    def dependent_implicit_edges
      edges_list = self.class.where(direct_edge: self).pluck(:id)
      loop do
        new_edges_list = self.class.where.not(id: edges_list)
          .and(
            self.class.where(entry_edge_id: edges_list).or(self.class.where(exit_edge_id: edges_list))
          )
        edges_list += new_edges_list
        break if new_edges_list.empty?
      end

      self.class.where(id: edges_list.excluding(id))
    end

    private

    def check_readonly
      _raise_readonly_record_error if readonly?
    end

    def add_implicit_edges!
      return unless direct?

      self.class.with_advisory_lock("dagger_#{self.class.table_name}") do
        self.class.where(id: id).update_all(entry_edge_id: id, direct_edge_id: id, exit_edge_id: id)

        direct_edges_count = self.class.direct.where(child: child).count
        if direct_edges_count > 1
          update_column :weight, weight / direct_edges_count
          self.class.direct.where(child: child).where.not(id: self).each do |edge|
            edge.update! weight: edge.weight * (direct_edges_count - 1) / direct_edges_count
          end
        end

        select = self.class.sanitize_sql_array(
          [
            "x.id, :id, :id, x.parent_id, :child_id, x.hops + 1, x.weight * :weight / 100, x.source",
            id: id, child_id: child_id, weight: weight
          ]
        )
        where = self.class.sanitize_sql_for_conditions(
          ["x.child_id = ? AND x.source = ?", parent_id, source]
        )
        self.class.connection.exec_insert insert_query(select, where)

        select = self.class.sanitize_sql_array(
          [
            ":id, :id, x.id, :parent_id, x.child_id, x.hops + 1, x.weight * :weight / 100, x.source",
            id: id, parent_id: parent_id, weight: weight
          ]
        )
        where = self.class.sanitize_sql_for_conditions(
          ["x.parent_id = ? AND x.source = ?", child_id, source]
        )
        self.class.connection.exec_insert insert_query(select, where)

        select = self.class.sanitize_sql_array(
          [
            "x.id, :id, y.id, x.parent_id, y.child_id, x.hops + y.hops + 2, x.weight * y.weight * :weight / 10000, x.source",
            id: id, weight: weight
          ]
        )
        where = self.class.sanitize_sql_for_conditions(
          ["x.child_id = ? AND y.parent_id = ? AND x.source = ?", parent_id, child_id, source]
        )
        self.class.connection.exec_insert insert_query(select, where, cross_join: true)
      end
    end

    def insert_query(select, where, cross_join: false)
      <<-SQL.squish
        INSERT INTO #{self.class.quoted_table_name}
          (entry_edge_id, direct_edge_id, exit_edge_id, parent_id, child_id, hops, weight, source)
          SELECT #{select}
          FROM #{self.class.quoted_table_name} x
          #{cross_join ? "CROSS JOIN #{self.class.quoted_table_name} y" : ''}
          WHERE #{where}
      SQL
    end

    def destroy_implicit_edges!
      return unless direct?

      dependent_implicit_edges.delete_all
    end

    def calculate_implicit_edges_weight!
      return unless direct? && weight_previously_changed?

      dependent_implicit_edges.update_all(
        self.class.sanitize_sql_array(["weight = weight * ? / ?", weight, weight_previously_was])
      )
    end

    def calculate_direct_edges_weight!
      direct_edges = self.class.direct.where(child: child)
      direct_edges.each do |edge|
        edge.update! weight: edge.weight + weight / direct_edges.size
      end
    end

    def _dagger_cycle_detection
      if parent == child || child.parent_of?(parent)
        errors.add :base, :cycle_detected, message: 'You cannot add a parent as a child'
      end
    end
  end
end
