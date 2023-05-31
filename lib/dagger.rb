# frozen_string_literal: true

require_relative "dagger/version"

require 'active_support'
require 'with_advisory_lock'

require_relative "dagger/has_directed_acyclic_graph"
require_relative "dagger/node_config"
require_relative "dagger/node_model"
require_relative "dagger/edge_model"

ActiveSupport.on_load :active_record do
  ActiveRecord::Base.send :extend, Dagger::HasDirectedAcyclicGraph
end
