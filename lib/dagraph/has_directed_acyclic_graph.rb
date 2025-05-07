module Dagraph
  module HasDirectedAcyclicGraph
    def has_directed_acyclic_graph(options = {})
      class_attribute :_dagraph
      self._dagraph = Dagraph::NodeConfig.new(self, **options)
      include Dagraph::NodeModel

      _dagraph.edges_class.is_directed_acyclic_graph_edge _dagraph
    end
    alias_method :has_dag, :has_directed_acyclic_graph

    def is_directed_acyclic_graph_edge(node_config)
      class_attribute :_dagraph
      self._dagraph = node_config

      include Dagraph::EdgeModel
    end
  end
end
