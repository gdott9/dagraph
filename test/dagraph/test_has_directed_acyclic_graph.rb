require 'test_helper'

describe Dagraph::HasDirectedAcyclicGraph do
  describe "when adding directed acyclic graph to model" do
    it "must add config in _dagraph variable" do
      assert_respond_to Node, :_dagraph
      assert_instance_of Dagraph::NodeConfig, Node._dagraph
    end

    it "must add config in _dagraph variable for edge model" do
      assert_respond_to NodeEdge, :_dagraph
      assert_equal Node._dagraph, NodeEdge._dagraph
    end
  end
end
