class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class NodeEdge < ApplicationRecord
end

class Node < ApplicationRecord
  has_directed_acyclic_graph
end
