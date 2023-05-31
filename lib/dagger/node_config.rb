module Dagger
  class NodeConfig
    def initialize(model_class, options)
      @model_class = model_class
      @options = options
    end

    def nodes_class_name
      @model_class.to_s
    end

    def nodes_class
      @model_class
    end

    def edges_class_name
      "#{@model_class}Edge"
    end

    def edges_class
      edges_class_name.constantize
    end
  end
end
