require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'node'
require 'edge'
require 'graph'
require 'algorithms'

describe Algorithms do
  it "should returns hash with proper distances" do
    nodes = (1..5).map { |id| Node.new(id) }
    edges = []
    edges << Edge.new(nodes[0], nodes[1], 1)
    edges << Edge.new(nodes[0], nodes[2], 2)
    edges << Edge.new(nodes[2], nodes[3], 3)
    edges << Edge.new(nodes[3], nodes[4], 4)
    graph = Graph.new(nodes, edges)
    Algorithms.dijkstra(graph, nodes[0].id).should == { 1=>0, 2=>1, 3=>2, 4=>5, 5=>9 }
  end
end

