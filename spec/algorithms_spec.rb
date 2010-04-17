require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'node'
require 'edge'
require 'graph'
require 'algorithms'

describe Algorithms do
  it "should returns hash with proper distances" do
    nodes = (1..5).map { |id| Node.new(id) }
    edges = []
    edges << Edge.new(nodes[0].id, nodes[1].id, 1)
    edges << Edge.new(nodes[0].id, nodes[2].id, 2)
    edges << Edge.new(nodes[2].id, nodes[3].id, 3)
    edges << Edge.new(nodes[3].id, nodes[4].id, 4)
    graph = Graph.new(nodes, edges)
    Algorithms.dijkstra(graph, nodes[0].id).should == { 1=>0, 2=>1, 3=>2, 4=>5, 5=>9 }
  end
end

