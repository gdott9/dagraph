# frozen_string_literal: true

require_relative "dagraph/version"

require 'active_support'
require 'with_advisory_lock'

require_relative "dagraph/has_directed_acyclic_graph"
require_relative "dagraph/node_config"
require_relative "dagraph/node_model"
require_relative "dagraph/edge_model"

ActiveSupport.on_load :active_record do
  ActiveRecord::Base.send :extend, Dagraph::HasDirectedAcyclicGraph
end
