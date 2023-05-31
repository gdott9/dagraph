module Dagger
  module HasDirectedAcyclicGraph
    def has_directed_acyclic_graph(options = {})
      class_attribute :_dagger
      self._dagger = Dagger::NodeConfig.new(self, options)
      include Dagger::NodeModel

      _dagger.edges_class.is_directed_acyclic_graph_edge _dagger
    end
    alias_method :has_dag, :has_directed_acyclic_graph

    def is_directed_acyclic_graph_edge(node_config)
      class_attribute :_dagger
      self._dagger = node_config

      include Dagger::EdgeModel
    end
  end
end
