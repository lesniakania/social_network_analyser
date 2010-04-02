class SocialNetworkAnalyser
  def self.degree_centrality(edges_model_sym, start_node_sym, node_id)
    DB[edges_model_sym.to_sym].filter(start_node_sym.to_sym => node_id).count
  end
end