# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Graph do
  before(:each) do
    @nodes = (0..5).map { |id| Node.new(id) }
    @edges = []
    @edges << Edge.new(@nodes[0], @nodes[1])
    @edges << Edge.new(@nodes[1], @nodes[0])
    @edges << Edge.new(@nodes[0], @nodes[2])
    @edges << Edge.new(@nodes[2], @nodes[0])
    @edges << Edge.new(@nodes[1], @nodes[4])
    @edges << Edge.new(@nodes[4], @nodes[1])
    @edges << Edge.new(@nodes[4], @nodes[3])
    @edges << Edge.new(@nodes[3], @nodes[4])
    @edges << Edge.new(@nodes[4], @nodes[5])
    @edges << Edge.new(@nodes[5], @nodes[4])
    
    subgraph0 = Graph.new([@nodes[0]], [])
    subgraph1 = Graph.new([@nodes[1]], [])
    subgraph2 = Graph.new([@nodes[2]], [])

    subgraph3 = Graph.new([@nodes[3]], [])
    subgraph4 = Graph.new([@nodes[4]], [])
    subgraph5 = Graph.new([@nodes[5]], [])

    @subgraph012 = Graph.new([], [])
    [subgraph0, subgraph1, subgraph2].each do |s|
      @subgraph012.add_subgraph(s)
    end
    @subgraph345 = Graph.new([], [])
    [subgraph3, subgraph4, subgraph5].each do |s|
      @subgraph345.add_subgraph(s)
    end

    @graph = Graph.new([], [])
    [@subgraph012, @subgraph345].each do |s|
      @graph.add_subgraph(s)
    end
  end

  it "should retrieve community nodes properly" do
    @graph.community_nodes.map { |n| n.id }.sort.should == [0, 1, 2, 3, 4, 5]
    @subgraph012.community_nodes.map { |n| n.id }.sort.should == [0, 1, 2]
    @subgraph345.community_nodes.map { |n| n.id }.sort.should == [3, 4, 5]
  end
end

