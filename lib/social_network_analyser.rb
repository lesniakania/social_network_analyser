class SocialNetworkAnalyser
  PageRankCoefficient = 0.85

  # Computes outdegree or indegree centrality depends on node_sym argument (start node symbol for outdegree, end node symbol for indegree).
  #
  #   +-------+     +-----------------------+
  #   | users |     |     user_followers    |
  #   +-------+     +---------+-------------+
  #   |  id   |     | user_id | follower_id |
  #   +-------+     +---------+-------------+
  #   |   1   |     |    1    |     2       |
  #   |   2   |     |    1    |     3       |
  #   |   3   |     |    1    |     4       |
  #   |   4   |     |    2    |     3       |
  #   +-------+     +---------+-------------+
  #
  #   # indegree_centrality
  #   SocialNetworkAnalyser.degree_centrality(:user_followers, :user_id, 1) #=> 3
  #   # outdegree_centrality
  #   SocialNetworkAnalyser.degree_centrality(:user_followers, :follower_id, 3) #=> 2
  def self.degree_centrality(edges_model_sym, node_sym, node_id)
    DB[edges_model_sym.to_sym].filter(node_sym.to_sym => node_id).count
  end

  # Computes page rank according to equation
  #   page_rank(x) = 1-d + d * (page_rank(y_1)/outdegree_centrality(y_1) + ... + page_rank(y_n)/outdegree_centrality(y_n))
  #
  #   where
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

  # Computes betweenness centrality according to equation
  #   betweenness_centrality(x) = q_s1_t1(x)/q_s1_t1 + ... + q_sn_tn(x)/q_sn_tn
  #
  #   where
  #   q_s_t(x) is the number of shortest paths from s to t that x lies on
  #   q_s_t is the number of shortes paths from s to t
  def self.betweenness_centrality(nodes_model_sym, node_id_sym, edges_model_sym, start_node_sym, end_node_sym, node_id)
    betweenness = {}
    fi = {}
    DB[nodes_model_sym.to_sym].map { |n| n[node_id_sym.to_sym] }.each do |n_id|
      betweenness[n_id] = 0.0
      fi[n_id] = 0.0
    end
    DB[nodes_model_sym.to_sym].map { |n| n[node_id_sym.to_sym] }.each do |s_id|
      stack = []
      p = {}
      q = {}
      d = {}
      DB[nodes_model_sym.to_sym].map { |n| n[node_id_sym.to_sym] }.each do |w_id|
        p[w_id] = []
        q[w_id] = 0.0
        d[w_id] = -1.0
      end
      q[s_id] = 1.0
      d[s_id] = 0.0
      queue = [s_id]
      while !queue.empty?
        v_id = queue.shift
        stack.push(v_id)
        DB[edges_model_sym.to_sym].filter(start_node_sym.to_sym => v_id).map { |n| n[end_node_sym.to_sym] }.each do |w_id|
          # w found for the first time?
          if d[w_id]<0
            queue << w_id
            d[w_id] = d[v_id]+1
          end
          # shortest path to w via v?
          if d[w_id] == d[v_id]+1
            q[w_id] += q[v_id]
            p[w_id] << v_id
          end
        end
      end
      while !stack.empty?
        w_id = stack.pop
        p[w_id].each do |v_id|
          fi[v_id] += (q[v_id].to_f/q[w_id].to_f)*(1+fi[w_id])
        end
        if w_id != s_id
          betweenness[w_id] += fi[w_id]
        end
      end
    end
    betweenness[node_id]
  end
end