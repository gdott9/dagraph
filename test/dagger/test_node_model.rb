require 'test_helper'

describe Dagger::NodeModel do
  before do
    Node.create! [
      {name: 'A'},
      {name: 'B'},
      {name: 'C'},
      {name: 'D'},
      {name: 'E'},
      {name: 'F'},
      {name: 'G'},
    ]

    # ┌───┐      ┌───┐     ┌───┐
    # │ D │      │ A │    ┌│ F │
    # └─┬─┘      └┬─┬┘    │└─┬─┘
    #   │  ┌───┐  │ │     │  │
    #   └─►│ B │◄─┘ │     │  │
    #      └─┬─┘    ▼     │  ▼
    #        │    ┌───┐   │┌───┐
    #        └───►│ C │◄──┘│ G │
    #             └─┬─┘    └───┘
    #               │
    #               ▼
    #             ┌───┐
    #             │ E │
    #             └───┘
    NodeEdge.create! [
      {parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'B')},
      {parent: Node.find_by(name: 'B'), child: Node.find_by(name: 'C')},
      {parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'C')},
      {parent: Node.find_by(name: 'D'), child: Node.find_by(name: 'B')},
      {parent: Node.find_by(name: 'C'), child: Node.find_by(name: 'E')},
      {parent: Node.find_by(name: 'F'), child: Node.find_by(name: 'G')},
      {parent: Node.find_by(name: 'F'), child: Node.find_by(name: 'C')},
    ]
  end

  describe "methods" do
    it "should check if root" do
      assert Node.find_by(name: 'A').root?
      refute Node.find_by(name: 'C').root?
      refute Node.find_by(name: 'E').root?
    end

    it "should check if leaf" do
      refute Node.find_by(name: 'A').leaf?
      refute Node.find_by(name: 'C').leaf?
      assert Node.find_by(name: 'E').leaf?
    end

    it "should check if child" do
      refute Node.find_by(name: 'A').child?
      assert Node.find_by(name: 'C').child?
      assert Node.find_by(name: 'E').child?
    end

    it "should check if is parent of node" do
      node = Node.find_by(name: 'C')

      assert Node.find_by(name: 'A').parent_of?(node)
      assert Node.find_by(name: 'B').parent_of?(node)
      refute Node.find_by(name: 'C').parent_of?(node)
      assert Node.find_by(name: 'D').parent_of?(node)
      refute Node.find_by(name: 'E').parent_of?(node)
    end

    it "should check if is direct parent of node" do
      node = Node.find_by(name: 'C')

      assert Node.find_by(name: 'A').direct_parent_of?(node)
      assert Node.find_by(name: 'B').direct_parent_of?(node)
      refute Node.find_by(name: 'C').direct_parent_of?(node)
      refute Node.find_by(name: 'D').direct_parent_of?(node)
      refute Node.find_by(name: 'E').direct_parent_of?(node)
    end

    it "should check if is child of node" do
      node = Node.find_by(name: 'B')

      refute Node.find_by(name: 'A').child_of?(node)
      refute Node.find_by(name: 'B').child_of?(node)
      assert Node.find_by(name: 'C').child_of?(node)
      refute Node.find_by(name: 'D').child_of?(node)
      assert Node.find_by(name: 'E').child_of?(node)
    end

    it "should check if is direct child of node" do
      node = Node.find_by(name: 'B')

      refute Node.find_by(name: 'A').direct_child_of?(node)
      refute Node.find_by(name: 'B').direct_child_of?(node)
      assert Node.find_by(name: 'C').direct_child_of?(node)
      refute Node.find_by(name: 'D').direct_child_of?(node)
      refute Node.find_by(name: 'E').direct_child_of?(node)
    end

    it "should include self and children" do
      node = Node.find_by(name: 'B')

      assert_equal 3, node.self_and_children.count
      assert node.self_and_children.include?(node)
      assert node.self_and_children.include?(Node.find_by(name: 'C'))
      assert node.self_and_children.include?(Node.find_by(name: 'E'))
    end

    it "should get children at depth" do
      node = Node.find_by(name: 'B')

      assert_equal 0, node.children_at_depth(0).count

      assert_equal 1, node.children_at_depth(1).count
      assert node.children_at_depth(1).include?(Node.find_by(name: 'C'))

      assert_equal 1, node.children_at_depth(2).count
      assert node.children_at_depth(2).include?(Node.find_by(name: 'E'))

      assert_equal 0, node.children_at_depth(3).count
    end

    it "should get hash with parents" do
      node_a = Node.find_by(name: 'A')
      node_b = Node.find_by(name: 'B')
      node_c = Node.find_by(name: 'C')
      node_d = Node.find_by(name: 'D')
      node_f = Node.find_by(name: 'F')

      assert_equal({
        node_c => {
          node_a => {},
          node_b => {
            node_a => {},
            node_d => {},
          },
          node_f => {}
        }
      }, node_c.parents_to_hash)
    end

    it "should get hash with children" do
      node_a = Node.find_by(name: 'A')
      node_b = Node.find_by(name: 'B')
      node_c = Node.find_by(name: 'C')
      node_e = Node.find_by(name: 'E')

      assert_equal({
        node_a => {
          node_b => {
            node_c => {
              node_e => {}
            }
          },
          node_c => {
            node_e => {}
          }
        }
      }, node_a.children_to_hash)
    end
  end

  describe "associations" do
    it "should return direct parents" do
      node = Node.find_by(name: 'C')
      assert_equal 3, node.direct_parents.count
      assert node.direct_parents.include?(Node.find_by(name: 'A'))
      assert node.direct_parents.include?(Node.find_by(name: 'B'))
      assert node.direct_parents.include?(Node.find_by(name: 'F'))
    end

    it "should return all parents" do
      node = Node.find_by(name: 'C')
      assert_equal 4, node.parents.count
      assert node.parents.include?(Node.find_by(name: 'A'))
      assert node.parents.include?(Node.find_by(name: 'B'))
      assert node.parents.include?(Node.find_by(name: 'D'))
      assert node.parents.include?(Node.find_by(name: 'F'))
    end

    it "should return direct children" do
      node = Node.find_by(name: 'A')
      assert_equal 2, node.direct_children.count
      assert node.direct_children.include?(Node.find_by(name: 'B'))
      assert node.direct_children.include?(Node.find_by(name: 'C'))
    end

    it "should return all children" do
      node = Node.find_by(name: 'A')
      assert_equal 3, node.children.count
      assert node.children.include?(Node.find_by(name: 'B'))
      assert node.children.include?(Node.find_by(name: 'C'))
      assert node.children.include?(Node.find_by(name: 'E'))
    end

    it "should return roots of node" do
      node = Node.find_by(name: 'C')
      assert_equal 3, node.roots.count
      assert node.roots.include?(Node.find_by(name: 'A'))
      assert node.roots.include?(Node.find_by(name: 'D'))
      assert node.roots.include?(Node.find_by(name: 'F'))

      assert_equal 0, Node.find_by(name: 'F').roots.count
    end

    it "should return leaves of node" do
      node = Node.find_by(name: 'F')
      assert_equal 2, node.leaves.count
      assert node.leaves.include?(Node.find_by(name: 'E'))
      assert node.leaves.include?(Node.find_by(name: 'G'))

      assert_equal 0, Node.find_by(name: 'E').leaves.count
    end

    it "should manage direct parents" do
      existing_node = Node.find_by(name: 'B')
      new_node = Node.create! name: 'H'

      refute existing_node.direct_parents.include?(new_node)

      existing_node.direct_parents << new_node
      existing_node.reload

      assert existing_node.direct_parents.include?(new_node)

      existing_node.direct_parents.destroy(new_node)
      refute existing_node.direct_parents.include?(new_node)

      existing_node.direct_parents = [new_node]
      existing_node.reload

      assert_equal 1, existing_node.direct_parents.count
      assert existing_node.direct_parents.include?(new_node)

      existing_node.direct_parents.destroy(new_node)
      existing_node.reload

      refute existing_node.direct_parents.include?(new_node)

      existing_node.direct_parent_ids = [new_node.id]
      existing_node.reload

      assert_equal 1, existing_node.direct_parents.count
      assert existing_node.direct_parents.include?(new_node)
    end

    it "should manage direct children" do
      existing_node = Node.find_by(name: 'B')
      new_node = Node.create! name: 'H'

      refute existing_node.direct_children.include?(new_node)

      existing_node.direct_children << new_node
      existing_node.reload

      assert existing_node.direct_children.include?(new_node)

      existing_node.direct_children.destroy(new_node)
      refute existing_node.direct_children.include?(new_node)

      existing_node.direct_children = [new_node]
      existing_node.reload

      assert_equal 1, existing_node.direct_children.count
      assert existing_node.direct_children.include?(new_node)

      existing_node.direct_children.destroy(new_node)
      existing_node.reload

      refute existing_node.direct_children.include?(new_node)

      existing_node.direct_child_ids = [new_node.id]
      existing_node.reload

      assert_equal 1, existing_node.direct_children.count
      assert existing_node.direct_children.include?(new_node)
    end
  end

  describe "scopes" do
    it "should return roots" do
      roots = Node.roots
      assert_equal 3, roots.count
      assert roots.include?(Node.find_by(name: 'A'))
      assert roots.include?(Node.find_by(name: 'D'))
      assert roots.include?(Node.find_by(name: 'F'))
    end

    it "should return leaves" do
      leaves = Node.leaves
      assert_equal 2, leaves.count
      assert leaves.include?(Node.find_by(name: 'E'))
      assert leaves.include?(Node.find_by(name: 'G'))
    end
  end
end

