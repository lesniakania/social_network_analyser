require 'social_network_analyser'

class Graph
  attr_accessor :nodes, :edges, :subgraphs

  def initialize(nodes, edges)
    self.nodes = nodes
    self.edges = edges
    self.subgraphs = []
  end

  def add_subgraph(subgraph)
    self.subgraphs << subgraph
  end

  def strong_community?
    self.community_nodes.all? do |n|
      SocialNetworkAnalyser.indegree_centrality(self, n) > SocialNetworkAnalyser.outdegree_centrality(self, n)
    end
  end

  def weak_community?
    sum_in = 0
    sum_out = 0
    self.community_nodes.each do |n|
      sum_in += SocialNetworkAnalyser.indegree_centrality(self, n)
      sum_out += SocialNetworkAnalyser.outdegree_centrality(self, n)
    end
    sum_in > sum_out
  end
end
