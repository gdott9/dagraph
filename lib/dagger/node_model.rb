require 'active_support/concern'

module Dagger
  module NodeModel
    extend ActiveSupport::Concern

    included do
      scope :roots, -> { where.not id: _dagger.edges_class.select(:child_id) }
      scope :leaves, -> { where.not id: _dagger.edges_class.select(:parent_id) }

      has_many :parent_edges, class_name: _dagger.edges_class_name, foreign_key: :child_id
      has_many :parents, -> { distinct }, class_name: model_name.to_s, through: :parent_edges
      has_many :child_edges, class_name: _dagger.edges_class_name, foreign_key: :parent_id
      has_many :children, -> { distinct }, class_name: model_name.to_s, through: :child_edges

      has_many :roots, -> { distinct.roots }, class_name: model_name.to_s, through: :parent_edges, source: :parent
      has_many :leaves, -> { distinct.leaves }, class_name: model_name.to_s, through: :child_edges, source: :child

      has_many :direct_parent_edges, -> { direct }, class_name: _dagger.edges_class_name, foreign_key: :child_id, inverse_of: :child, dependent: :destroy
      has_many :direct_parents, -> { distinct }, class_name: model_name.to_s, through: :direct_parent_edges, source: :parent, dependent: :destroy
      has_many :direct_child_edges, -> { direct }, class_name: _dagger.edges_class_name, foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy
      has_many :direct_children, -> { distinct }, class_name: model_name.to_s, through: :direct_child_edges, source: :child, dependent: :destroy
    end

    def graph_to_hash
      hash = {self => {}}
      ids = {self => hash[self]}

      children.includes(:direct_parents).each do |child|
        ids[child] = {} unless ids.key?(child)
        child.direct_parents.each do |parent|
          ids[parent] = {} unless ids.key?(parent)
          ids[parent][child] = ids[child]
        end
      end

      hash
    end

    def children_at_depth(depth)
      self.class.where id: child_edges.where(hops: depth - 1).select(:child_id)
    end

    def self_and_children
      self.class.where(id: self).or(self.class.where(id: children))
    end

    def parent_of?(node)
      return false if node.nil?
      children.include?(node)
    end

    def child_of?(node)
      return false if node.nil?
      node.parent_of?(self)
    end

    def direct_parent_of?(node)
      return false if node.nil?
      direct_children.include?(node)
    end

    def direct_child_of?(node)
      return false if node.nil?
      node.parent_of?(self)
    end

    def root?
      parent_edges.empty?
    end

    def child?
      !root?
    end

    def leaf?
      child_edges.empty?
    end
  end
end
