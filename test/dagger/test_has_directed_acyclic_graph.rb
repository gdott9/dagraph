require 'test_helper'

describe Dagger::HasDirectedAcyclicGraph do
  describe "when adding directed acyclic graph to model" do
    it "must add config in _dagger variable" do
      assert_respond_to Node, :_dagger
      assert_instance_of Dagger::NodeConfig, Node._dagger
    end

    it "must add config in _dagger variable for edge model" do
      assert_respond_to NodeEdge, :_dagger
      assert_equal Node._dagger, NodeEdge._dagger
    end
  end
end
