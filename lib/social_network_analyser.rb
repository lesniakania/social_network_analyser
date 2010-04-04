class SocialNetworkAnalyser
  PageRankCoefficient = 0.85

  # - Computes outdegree or indegree centrality depends on node_sym argument.
  # - <b>outdegree centrality</b> requires <start node symbol> of your edge as node_sym.
  # - <b>indegree centrality</b> requires <end node symbol> of your edge as node_sym.
  # - <start node symbol> ---> <end node symbol>
  #  example:
  #   table users contains nodes
  #   table user_followers contains edges
  #   edge is <follower> ---> <user>
  #   <start node symbol> of this edge is :follower_id
  #   <end node symbol> of this edge is :user_id
  def self.degree_centrality(edges_model_sym, node_sym, node_id)
    DB[edges_model_sym.to_sym].filter(node_sym.to_sym => node_id).count
  end

  # page rank is compute according to equation
  #  page_rank(x) = 1-d + d * (page_rank(y_1)/outdegree_centrality(y_1) + ... + page_rank(y_n)/outdegree_centrality(y_n))
  #  where
  #   d is page rank coefficient
  #   y_1...y_n are start nodes from incomming x edges
  def self.page_rank(edges_model_sym, start_node_sym, end_node_sym, node_id)
    page_ranks = {}
    queue = [node_id]

    while !queue.empty?
      node_id = queue.shift
      neighbour_ids = DB[edges_model_sym.to_sym].filter(end_node_sym.to_sym => node_id).map { |n| n[start_node_sym.to_sym] }.
        select { |n| !queue.include?(n) }

      node_id.to_s + " " + neighbour_ids.to_s
      if !neighbour_ids.empty?
        if neighbour_ids.all? { |neighbour_id| page_ranks[neighbour_id] }
          sum = 0
          neighbour_ids.each do |neighbour_id|
            outdegree_centrality = degree_centrality(edges_model_sym, start_node_sym, neighbour_id)
            if outdegree_centrality != 0
              sum += page_ranks[neighbour_id]/outdegree_centrality.to_f
            else
              sum += page_ranks[neighbour_id]
            end
          end
          page_ranks[node_id] = (1-PageRankCoefficient) + PageRankCoefficient*sum
        else
          queue.unshift(node_id)
          queue = neighbour_ids + queue
        end
      else
        outdegree_centrality = degree_centrality(edges_model_sym, start_node_sym, node_id)
        if outdegree_centrality != 0
          page_ranks[node_id] = (1-PageRankCoefficient) + neighbour_ids.count/outdegree_centrality.to_f
        else
          page_ranks[node_id] = (1-PageRankCoefficient) + neighbour_ids.count
        end
      end
    end

    page_ranks[node_id]
  end
end