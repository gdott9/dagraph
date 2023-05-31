require 'active_support/concern'

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

      after_create :add_implicit_edges!
    end

    def direct?
      hops.zero?
    end

    private

    def add_implicit_edges!
      return unless direct?

      self.class.with_advisory_lock("dagger_#{self.class.table_name}") do
        update! entry_edge: self, direct_edge: self, exit_edge: self

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
            "x.id, :id, y.id, x.parent_id, y.child_id, x.hops + y.hops + 2, x.weight * :weight / 100, x.source",
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
  end
end
