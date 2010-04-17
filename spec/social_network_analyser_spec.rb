require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'social_network_analyser'
require 'node'
require 'edge'
require 'graph'

describe SocialNetworkAnalyser do
  before(:each) do
    @nodes = (1..5).map { |id| Node.new(id) }
  end

  describe "degree centrality" do
    it "should compute outdegree centrality properly" do
      src = Node.new(6)
      edges = []
      @nodes.each { |n| edges << Edge.new(src.id, n.id) }
      graph = Graph.new(@nodes, edges)
      SocialNetworkAnalyser.outdegree_centrality(graph, src.id).should == 5
    end
    
    it "should compute indegree centrality properly" do
      src = Node.new(6)
      edges = []
      @nodes.each { |n| edges << Edge.new(n.id, src.id) }
      graph = Graph.new(@nodes, edges)
      SocialNetworkAnalyser.indegree_centrality(graph, src.id).should == 5
    end
  end

  describe "page rank" do
    it "should compute page rank properly" do
      edges = []
      edges << Edge.new(@nodes[0].id, @nodes[1].id)
      edges << Edge.new(@nodes[0].id, @nodes[2].id)
      edges << Edge.new(@nodes[1].id, @nodes[3].id)
      edges << Edge.new(@nodes[1].id, @nodes[4].id)
      edges << Edge.new(@nodes[2].id, @nodes[3].id)
      edges << Edge.new(@nodes[2].id, @nodes[4].id)
      edges << Edge.new(@nodes[3].id, @nodes[4].id)
      graph = Graph.new(@nodes, edges)
      SocialNetworkAnalyser.page_rank(graph, @nodes[4].id).should == 0.613621875
    end
  end

  describe "betweenness centrality" do
    it "should compute betweenness centrality properly" do
      (6..7).each { |id| @nodes << Node.new(id) }
      edges = []
      edges << Edge.new(@nodes[0].id, @nodes[1].id)
      edges << Edge.new(@nodes[1].id, @nodes[2].id)
      edges << Edge.new(@nodes[2].id, @nodes[3].id)
      edges << Edge.new(@nodes[0].id, @nodes[4].id)
      edges << Edge.new(@nodes[1].id, @nodes[5].id)
      edges << Edge.new(@nodes[4].id, @nodes[5].id)
      edges << Edge.new(@nodes[5].id, @nodes[6].id)
      graph = Graph.new(@nodes, edges)
      SocialNetworkAnalyser.betweenness_centrality(graph, @nodes[1].id).should == 3
      SocialNetworkAnalyser.betweenness_centrality(graph, @nodes[4].id).should == 1
    end
  end

  describe "centrality based on dijkstra alghoritm" do
    before(:each) do
      @edges = []
      @edges << Edge.new(@nodes[0].id, @nodes[1].id)
      @edges << Edge.new(@nodes[0].id, @nodes[2].id)
      @edges << Edge.new(@nodes[2].id, @nodes[3].id)
      @edges << Edge.new(@nodes[3].id, @nodes[4].id)
      @graph = Graph.new(@nodes, @edges)
    end

    describe "closeness centrality" do
      it "should compute closeness centrality properly" do
        SocialNetworkAnalyser.closeness_centrality(@graph, @nodes[0].id).should == 1.0/7
      end
    end

    describe "graph centrality" do
      it "should compute graph centrality properly" do
        SocialNetworkAnalyser.graph_centrality(@graph, @nodes[0].id).should == 1.0/3
      end
    end
  end
end
