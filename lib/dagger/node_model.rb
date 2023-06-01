require 'active_support/concern'

module Dagger
  module NodeModel
    extend ActiveSupport::Concern

    included do
      has_many :parent_edges, class_name: _dagger.edges_class_name, foreign_key: :child_id
      has_many :parents, -> { distinct }, class_name: model_name.to_s, through: :parent_edges
      has_many :child_edges, class_name: _dagger.edges_class_name, foreign_key: :parent_id
      has_many :children, -> { distinct }, class_name: model_name.to_s, through: :child_edges

      has_many :direct_parent_edges, -> { direct }, class_name: _dagger.edges_class_name, foreign_key: :child_id
      has_many :direct_parents, -> { distinct }, class_name: model_name.to_s, through: :direct_parent_edges, source: :parent
      has_many :direct_child_edges, -> { direct }, class_name: _dagger.edges_class_name, foreign_key: :parent_id
      has_many :direct_children, -> { distinct }, class_name: model_name.to_s, through: :direct_child_edges, source: :child
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
