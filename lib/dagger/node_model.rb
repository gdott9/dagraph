require 'active_support/concern'

module Dagger
  module NodeModel
    extend ActiveSupport::Concern

    included do
      has_many :parent_edges, -> { direct }, class_name: _dagger.edges_class_name, foreign_key: :child_id
      has_many :child_edges, -> { direct }, class_name: _dagger.edges_class_name, foreign_key: :parent_id
    end
  end
end
