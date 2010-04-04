require 'edge'

class Graph
  attr_accessor :nodes, :edges

  # Creates graph from given array of nodes and edges represented as three-element array - start node, end node and weight.
  def initialize(nodes, edges)
    self.nodes = nodes
    self.edges = edges.map { |e| Edge.new(e[0], e[1], e[2]) }
  end
end
