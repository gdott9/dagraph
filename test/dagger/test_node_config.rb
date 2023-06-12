require 'test_helper'

describe Dagger::NodeConfig do
  before do
    @node_config = Dagger::NodeConfig.new(Node)
  end

  it "must return nodes class" do
    assert_equal Node, @node_config.nodes_class
  end

  it "must return edges class" do
    assert_equal NodeEdge, @node_config.edges_class
  end

  it "must return nodes class name" do
    assert_equal 'Node', @node_config.nodes_class_name
  end

  it "must return edges class name" do
    assert_equal 'NodeEdge', @node_config.edges_class_name
  end
end
