require 'social_network_analyser'

class Graph
  attr_accessor :id, :nodes, :edges, :subgraphs, :strength

  def initialize(nodes, edges)
    self.nodes = {}
    nodes.each do |n|
      self.nodes[n.id] = n
    end
    self.edges = {}
    edges.each do |e|
      self.edges[e.id] = e
    end
    self.subgraphs = []
    sum_in, sum_out = get_k_in_and_sum_k_out
    self.strength = (sum_out>0 ? sum_in.to_f/sum_out : 0.0)
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
    sum_in, sum_out = get_k_in_and_sum_k_out
    sum_in > sum_out
  end

  # Retrieves community nodes for given graph
  def community_nodes
    community_nodes = []
    community_nodes += self.nodes.values
    self.subgraphs.each do |sub|
      community_nodes += sub.community_nodes
    end
    community_nodes
  end

  def <=>(subgraph)
    Set.new(self.nodes.keys) <=> Set.new(subgraph.nodes.keys)
  end

  def ==(subgraph)
    Set.new(self.nodes.keys) == Set.new(subgraph.nodes.keys)
  end

  private

  def get_k_in_and_sum_k_out
    sum_in = 0
    sum_out = 0
    self.nodes.each do |n_id, n|
      sum_in += SocialNetworkAnalyser.indegree_centrality(self, n_id) + SocialNetworkAnalyser.outdegree_centrality(self, n_id)
      sum_out += n.k_out
    end
    [sum_in, sum_out]
  end
end
