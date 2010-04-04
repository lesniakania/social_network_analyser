require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'graph'
require 'algorithms'

describe Algorithms do
  it "should returns hash with proper distances" do
    g = Graph.new([1,2,3,4,5], [[1,2,1],[1,3,2],[3,4,3],[4,5,4]])
    Algorithms.dijkstra(g, 1).should == { 1=>0, 2=>1, 3=>2, 4=>5, 5=>9 }
  end
end

