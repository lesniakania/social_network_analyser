class SocialNetworkAnalyser
  PageRankCoefficient = 0.85

  # Computes outdegree or indegree centrality depending on node_sym argument (start node symbol for outdegree, end node symbol for indegree).
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
  def self.indegree_centrality(graph, src_id)
    graph.edges.select { |e| e.v_end == src_id }.size
  end

  def self.outdegree_centrality(graph, src_id)
    graph.edges.select { |e| e.v_start == src_id }.size
  end

  # Computes page rank according to equation
  #   page_rank(x) = 1-d + d * (page_rank(y_1)/outdegree_centrality(y_1) + ... + page_rank(y_n)/outdegree_centrality(y_n))
  #
  #   where
  #   d is page rank coefficient
  #   y_1...y_n are start nodes from incomming x edges
  def self.page_rank(graph, src_id)
    page_ranks = {}
    queue = [src_id]

    while !queue.empty?
      node_id = queue.shift
      neighbour_ids = graph.edges.select { |e| e.v_end == node_id }.map { |e| e.v_start }.select { |n| !queue.include?(n) }

      if !neighbour_ids.empty?
        if neighbour_ids.all? { |neighbour_id| page_ranks[neighbour_id] }
          sum = 0
          neighbour_ids.each do |neighbour_id|
            outdegree_centrality = outdegree_centrality(graph, neighbour_id)
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
        outdegree_centrality = outdegree_centrality(graph, node_id)
        if outdegree_centrality != 0
          page_ranks[node_id] = (1-PageRankCoefficient) + neighbour_ids.count/outdegree_centrality.to_f
        else
          page_ranks[node_id] = (1-PageRankCoefficient) + neighbour_ids.count
        end
      end
    end

    page_ranks[src_id]
  end

  # Computes betweenness centrality according to equation
  #   betweenness_centrality(x) = q_s1_t1(x)/q_s1_t1 + ... + q_sn_tn(x)/q_sn_tn
  #
  #   where
  #   q_s_t(x) is the number of shortest paths from s to t that x lies on
  #   q_s_t is the number of shortes paths from s to t
  def self.betweenness_centrality(graph, src_id)
    betweenness = {}
    fi = {}
    graph.nodes.map { |n| n.id }.each do |n_id|
      betweenness[n_id] = 0.0
      fi[n_id] = 0.0
    end
    graph.nodes.map { |n| n.id }.each do |s_id|
      stack = []
      p = {}
      q = {}
      d = {}
      graph.nodes.map { |n| n.id }.each do |w_id|
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
        graph.edges.select { |e| e.v_start == v_id }.map { |e| e.v_end }.each do |w_id|
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
    betweenness[src_id]
  end

  # Computes closeness centrality according to equation
  #   closeness_centrality(x) = 1/(d(x,t1) + ... + d(x,tn))
  #
  #   where
  #   d(x,y) is the shortest distance from x to y
  def self.closeness_centrality(graph, src_id)
    1.0/Algorithms.dijkstra(graph, src_id).values.inject(0) { |sum, d| sum+d }
  end

  # Computes closeness centrality according to equation
  #   graph_centrality(x) = 1/max(d(x,t1),...,d(x,tn))
  #
  #   where
  #   d(x,y) is the shortest distance from x to y
  def self.graph_centrality(graph, src_id)
    1.0/Algorithms.dijkstra(graph, src_id).values.max
  end
end