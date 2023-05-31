# frozen_string_literal: true

ActiveRecord::Schema.define(version: 0) do
  create_table 'nodes', force: true do |t|
    t.string :name
    t.timestamps null: false
  end

  create_table 'node_edges', force: true do |t|
    t.references :entry_edge, foreign_key: {to_table: :node_edges}
    t.references :direct_edge, foreign_key: {to_table: :node_edges}
    t.references :exit_edge, foreign_key: {to_table: :node_edges}
    t.references :parent, null: false, foreign_key: {to_table: :nodes}
    t.references :child, null: false, foreign_key: {to_table: :nodes}
    t.integer :hops, index: true, null: false
    t.integer :weight, null: false, default: 100
    t.string :source, index: true, null: false, default: 'default'
  end
end
