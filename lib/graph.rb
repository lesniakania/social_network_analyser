require 'social_network_analyser'

class Graph
  attr_accessor :id, :nodes, :edges, :subgraphs

  def initialize(nodes, edges)
    self.nodes = {}
    nodes.each do |n|
      self.nodes[n.id] = n
    end
    self.edges = {}
    edges.each do |e|
      self.edges[e.id] = e
    end
    self.id = self.nodes.keys.sort.join("-")
    self.subgraphs = []
  end

  # Adds subgraph to graph
  def add_subgraph(subgraph)
    self.subgraphs << subgraph
  end

  # Checks if graph is community according to definition
  #   k_in_i(self) > k_out_i(self), for every (sub)graph node
  #
  #   where
  #     k_in  is degree of edges in (sub)graph
  #     k_out is degree of edges out of (sub)graph
  def strong_community?
    self.nodes.all? do |n_id, n|
      k_in = SocialNetworkAnalyser.indegree_centrality(self, n_id) + SocialNetworkAnalyser.outdegree_centrality(self, n_id)
      k_in > n.k_out
    end
  end

  # Checks if graph is community according to definition
  #   k_in_1(self) + .., + k_in_n(self) > k_out_1(self) + .. + k_out_n(self)
  #
  #   where
  #     k_in  is degree of edges in (sub)graph
  #     k_out is degree of edges out of (sub)graph
  def weak_community?
    sum_in = 0
    sum_out = 0
    self.nodes.each do |n_id, n|
      sum_in += SocialNetworkAnalyser.indegree_centrality(self, n_id) + SocialNetworkAnalyser.outdegree_centrality(self, n_id)
      sum_out += n.k_out
    end
    sum_in > sum_out
  end

  # Retrieves community nodes for given graph
  def community_nodes
    cn = []
    if self.nodes.empty? && !self.subgraphs.empty?
      self.subgraphs.each do |s|
        cn += s.community_nodes
      end
      cn
    else
      self.nodes.values
    end
  end

  def <=>(subgraph)
    self.id <=> subgraph.id
  end

  def ==(subgraph)
    self.id == subgraph.id
  end
end
