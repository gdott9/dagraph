require 'test_helper'

describe Dagger::EdgeModel do
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
  end

  describe "when adding edges" do
    it "should add single edge" do
      # ┌───┐
      # │ A │
      # └─┬─┘
      #   ▼
      # ┌───┐
      # │ B │
      # └───┘
      assert NodeEdge.create(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'B'))
      assert_equal 1, NodeEdge.count
    end

    it "should add implicit edges" do
      #       ┌───┐
      #       │ A │
      #       └┬─┬┘
      # ┌───┐  │ │
      # │ C │◄─┘ │
      # └───┘    ▼
      #        ┌───┐
      #        │ B │
      #        └─┬─┘
      #          │
      #          ▼
      #        ┌───┐
      #        │ D │
      #        └───┘
      NodeEdge.create!(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'B'))
      assert_equal 1, NodeEdge.count

      NodeEdge.create!(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'C'))
      assert_equal 2, NodeEdge.count

      NodeEdge.create!(parent: Node.find_by(name: 'B'), child: Node.find_by(name: 'D'))
      assert_equal 2, NodeEdge.where(child: Node.find_by(name: 'D')).count
      assert NodeEdge.where(
        parent: Node.find_by(name: 'A'),
        child: Node.find_by(name: 'D'),
        hops: 1
      )
    end

    it "should calculate correct weight" do
      # ┌───┐  ┌───┐  ┌───┐
      # │ A │  │ C │  │ D │
      # └─┬─┘  └─┬─┘  └─┬─┘
      #   │      ▼      │
      #   │    ┌───┐    │  ┌───┐
      #   └───►│ B │◄───┘  │ F │
      #        └─┬─┘       └─┬─┘
      #          ▼           │
      #        ┌───┐         │
      #        │ E │◄────────┘
      #        └───┘
      edge_a_b = NodeEdge.create(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'B'))
      assert_equal 100, edge_a_b.weight

      edge_c_b = NodeEdge.create(parent: Node.find_by(name: 'C'), child: Node.find_by(name: 'B'))
      assert_equal 50, edge_c_b.weight
      assert_equal 50, edge_a_b.reload.weight

      edge_d_b = NodeEdge.create(parent: Node.find_by(name: 'D'), child: Node.find_by(name: 'B'))
      assert_equal 100/3.0, edge_d_b.weight
      assert_equal 100/3.0, edge_c_b.reload.weight
      assert_equal 100/3.0, edge_a_b.reload.weight

      edge_b_e = NodeEdge.create(parent: Node.find_by(name: 'B'), child: Node.find_by(name: 'E'))
      assert_equal 100, edge_b_e.weight
      assert_equal 100/3.0, edge_d_b.reload.weight
      assert_equal 100/3.0, edge_c_b.reload.weight
      assert_equal 100/3.0, edge_a_b.reload.weight
      assert_equal 100/3.0, NodeEdge.find_by(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'E'), hops: 1).weight
      assert_equal 100/3.0, NodeEdge.find_by(parent: Node.find_by(name: 'C'), child: Node.find_by(name: 'E'), hops: 1).weight
      assert_equal 100/3.0, NodeEdge.find_by(parent: Node.find_by(name: 'D'), child: Node.find_by(name: 'E'), hops: 1).weight

      edge_f_e = NodeEdge.create(parent: Node.find_by(name: 'F'), child: Node.find_by(name: 'E'))
      assert_equal 50, edge_f_e.weight
      assert_equal 50, edge_b_e.reload.weight
      assert_equal 100/3.0, edge_d_b.reload.weight
      assert_equal 100/3.0, edge_c_b.reload.weight
      assert_equal 100/3.0, edge_a_b.reload.weight
      assert_equal 100/6.0, NodeEdge.find_by(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'E'), hops: 1).weight
      assert_equal 100/6.0, NodeEdge.find_by(parent: Node.find_by(name: 'C'), child: Node.find_by(name: 'E'), hops: 1).weight
      assert_equal 100/6.0, NodeEdge.find_by(parent: Node.find_by(name: 'D'), child: Node.find_by(name: 'E'), hops: 1).weight
    end

    it "should recaclulate implicit edges weight" do
      # ┌───┐
      # │ A │
      # └─┬─┘
      #   ▼
      # ┌───┐
      # │ B │ ┌───┐
      # └─┬─┘ │ E │
      #   ▼   └─┬─┘
      # ┌───┐   │
      # │ C │◄──┘
      # └─┬─┘
      #   ▼
      # ┌───┐
      # │ D │
      # └─┬─┘
      #   ▼
      # ┌───┐
      # │ F │
      # └───┘
      edge_a_b = NodeEdge.create(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'B'))
      edge_b_c = NodeEdge.create(parent: Node.find_by(name: 'B'), child: Node.find_by(name: 'C'))
      edge_e_c = NodeEdge.create(parent: Node.find_by(name: 'E'), child: Node.find_by(name: 'C'))
      edge_c_d = NodeEdge.create(parent: Node.find_by(name: 'C'), child: Node.find_by(name: 'D'))
      edge_d_f = NodeEdge.create(parent: Node.find_by(name: 'D'), child: Node.find_by(name: 'F'))

      assert_equal 50, NodeEdge.find_by(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'C'), hops: 1).weight
      assert_equal 50, NodeEdge.find_by(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'D'), hops: 2).weight
      assert_equal 50, NodeEdge.find_by(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'F'), hops: 3).weight
      assert_equal 50, NodeEdge.find_by(parent: Node.find_by(name: 'B'), child: Node.find_by(name: 'D'), hops: 1).weight
      assert_equal 50, NodeEdge.find_by(parent: Node.find_by(name: 'B'), child: Node.find_by(name: 'F'), hops: 2).weight
      assert_equal 50, NodeEdge.find_by(parent: Node.find_by(name: 'E'), child: Node.find_by(name: 'D'), hops: 1).weight
      assert_equal 50, NodeEdge.find_by(parent: Node.find_by(name: 'E'), child: Node.find_by(name: 'F'), hops: 2).weight

      edge_c_d.update! weight: 20

      assert_equal 100, edge_a_b.reload.weight
      assert_equal 50, edge_b_c.reload.weight
      assert_equal 50, edge_e_c.reload.weight
      assert_equal 20, edge_c_d.reload.weight
      assert_equal 100, edge_d_f.reload.weight

      assert_equal 50, NodeEdge.find_by(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'C'), hops: 1).weight
      assert_equal 10, NodeEdge.find_by(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'D'), hops: 2).weight
      assert_equal 10, NodeEdge.find_by(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'F'), hops: 3).weight

      assert_equal 10, NodeEdge.find_by(parent: Node.find_by(name: 'B'), child: Node.find_by(name: 'D'), hops: 1).weight
      assert_equal 10, NodeEdge.find_by(parent: Node.find_by(name: 'B'), child: Node.find_by(name: 'F'), hops: 2).weight
      assert_equal 10, NodeEdge.find_by(parent: Node.find_by(name: 'E'), child: Node.find_by(name: 'D'), hops: 1).weight
      assert_equal 10, NodeEdge.find_by(parent: Node.find_by(name: 'E'), child: Node.find_by(name: 'F'), hops: 2).weight
    end

    it "should prevent cycles" do
      # ┌───┐
      # │ A │
      # └─┬─┘
      #   ▼
      # ┌───┐
      # │ B │
      # └─┬─┘
      #   ▼
      # ┌───┐
      # │ C │
      # └───┘
      NodeEdge.create(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'B'))
      NodeEdge.create(parent: Node.find_by(name: 'B'), child: Node.find_by(name: 'C'))

      edge_c_a = NodeEdge.new(parent: Node.find_by(name: 'C'), child: Node.find_by(name: 'A'))

      refute edge_c_a.valid?
      assert edge_c_a.errors.added?(:base, :cycle_detected)
    end
  end

  describe "when querying edges" do
    before do
      # ┌───┐      ┌───┐     ┌───┐
      # │ D │      │ A │     │ F │
      # └─┬─┘      └┬─┬┘     └─┬─┘
      #   │  ┌───┐  │ │        │
      #   └─►│ B │◄─┘ │        │
      #      └─┬─┘    ▼        ▼
      #        │    ┌───┐    ┌───┐
      #        └───►│ C │◄───│ G │
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
        {parent: Node.find_by(name: 'G'), child: Node.find_by(name: 'C')},
      ]
    end

    it "should have readonly attributes" do
      assert_equal Set.new(['entry_edge_id', 'direct_edge_id', 'exit_edge_id', 'parent_id', 'child_id', 'hops', 'source']),
        NodeEdge.attr_readonly
    end

    it "should return direct edges" do
      direct_edges = NodeEdge.direct
      assert_equal 7, direct_edges.count
      assert direct_edges.all?(&:direct?)
      refute direct_edges.any?(&:implicit?)
    end

    it "should return direct edges" do
      implicit_edges = NodeEdge.implicit
      assert_equal 9, implicit_edges.count
    end

    it "should set readonly for implicit edges" do
      assert NodeEdge.implicit.all?(&:readonly?)
    end

    it "should get dependent implicit edges" do
      edge = NodeEdge.direct.where(parent: Node.find_by(name: 'B'), child: Node.find_by(name: 'C')).first
      assert_equal 5, edge.dependent_implicit_edges.count

      assert edge.dependent_implicit_edges.where(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'C'), hops: 1).any?
      assert edge.dependent_implicit_edges.where(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'E'), hops: 2).any?
      assert edge.dependent_implicit_edges.where(parent: Node.find_by(name: 'B'), child: Node.find_by(name: 'E'), hops: 1).any?
      assert edge.dependent_implicit_edges.where(parent: Node.find_by(name: 'D'), child: Node.find_by(name: 'C'), hops: 1).any?
      assert edge.dependent_implicit_edges.where(parent: Node.find_by(name: 'D'), child: Node.find_by(name: 'E'), hops: 2).any?
    end
  end

  describe "when removing edges" do
    it "should recaclulate implicit edges weight" do
      # ┌───┐
      # │ A │
      # └─┬─┘
      #   ▼
      # ┌───┐
      # │ B │ ┌───┐
      # └─┬─┘ │ E │
      #   ▼   └─┬─┘
      # ┌───┐   │
      # │ C │◄──┘
      # └───┘
      NodeEdge.create(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'B'))
      edge_b_c = NodeEdge.create(parent: Node.find_by(name: 'B'), child: Node.find_by(name: 'C'))
      edge_d_c = NodeEdge.create(parent: Node.find_by(name: 'D'), child: Node.find_by(name: 'C'))
      edge_e_c = NodeEdge.create(parent: Node.find_by(name: 'E'), child: Node.find_by(name: 'C'))
      edge_f_c = NodeEdge.create(parent: Node.find_by(name: 'F'), child: Node.find_by(name: 'C'))

      assert_equal 25, edge_b_c.reload.weight
      assert_equal 25, edge_d_c.reload.weight
      assert_equal 25, edge_e_c.reload.weight
      assert_equal 25, edge_f_c.reload.weight
      assert_equal 25, NodeEdge.find_by(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'C'), hops: 1).weight

      edge_f_c.destroy!

      assert_equal 100 / 3.0, edge_b_c.reload.weight
      assert_equal 100 / 3.0, edge_d_c.reload.weight
      assert_equal 100 / 3.0, edge_e_c.reload.weight
      assert_equal 100 / 3.0, NodeEdge.find_by(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'C'), hops: 1).weight

      edge_e_c.destroy!

      assert_equal 50, edge_b_c.reload.weight
      assert_equal 50, edge_d_c.reload.weight
      assert_equal 50, NodeEdge.find_by(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'C'), hops: 1).weight

      edge_d_c.destroy!

      assert_equal 100, edge_b_c.reload.weight
      assert_equal 100, NodeEdge.find_by(parent: Node.find_by(name: 'A'), child: Node.find_by(name: 'C'), hops: 1).weight

      edge_b_c.destroy!
    end
  end
end
