require 'config/init'
require 'algorithms'

class SocialNetworkAnalyser
  PageRankCoefficient = 0.85

  # Computes indegree centrality
  #   nodes = (1..5).map { |id| Node.new(id) }
  #   src = Node.new(6)
  #   edges = []
  #   nodes.each { |n| edges << Edge.new(n, src) }
  #   nodes << src
  #   graph = Graph.new(nodes, edges)
  #
  #   SocialNetworkAnalyser.indegree_centrality(graph, src.id) #=> 5
  def self.indegree_centrality(graph, src_id)
    graph.edges.values.select { |e| e.v_end.id == src_id }.size
  end

  # Computes outdegree centrality
  #   nodes = (1..5).map { |id| Node.new(id) }
  #   src = Node.new(6)
  #   edges = []
  #   nodes.each { |n| edges << Edge.new(src, n) }
  #   nodes << src
  #   graph = Graph.new(nodes, edges)
  #
  #   SocialNetworkAnalyser.outdegree_centrality(graph, src.id) #=> 5
  def self.outdegree_centrality(graph, src_id)
    graph.edges.values.select { |e| e.v_start.id == src_id }.size
  end

  # Computes page rank according to equation
  #   page_rank(x) = 1-d + d * (page_rank(y_1)/outdegree_centrality(y_1) + ... + page_rank(y_n)/outdegree_centrality(y_n))
  #
  #   where
  #   d is page rank coefficient
  #   y_1...y_n are start nodes from incomming x edges
  #
  #   nodes = (1..5).map { |id| Node.new(id) }
  #   edges = []
  #   edges << Edge.new(nodes[0], nodes[1])
  #   edges << Edge.new(nodes[0], nodes[2])
  #   edges << Edge.new(nodes[1], nodes[3])
  #   edges << Edge.new(nodes[1], nodes[4])
  #   edges << Edge.new(nodes[2], nodes[3])
  #   edges << Edge.new(nodes[2], nodes[4])
  #   edges << Edge.new(nodes[3], nodes[4])
  #   graph = Graph.new(nodes, edges)
  #
  #   SocialNetworkAnalyser.page_rank(graph, nodes[4].id) #=> 0.613621875
  def self.page_rank(graph, src_id)
    page_ranks = {}
    queue = [src_id]

    while !queue.empty?
      node_id = queue.shift
      neighbour_ids = graph.edges.values.select { |e| e.v_end.id == node_id }.map { |e| e.v_start.id }.
        select { |n| !queue.include?(n) }

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
        page_ranks[node_id] = 1-PageRankCoefficient
      end
    end
    
    page_ranks[src_id]
  end

  # Computes betweenness centrality according to equation. Returns hash with node ids as keys and their betweenness as values.
  #   betweenness_centrality(x) = q_s1_t1(x)/q_s1_t1 + ... + q_sn_tn(x)/q_sn_tn
  #
  #   where
  #   q_s_t(x) is the number of shortest paths from s to t that x lies on
  #   q_s_t is the number of shortes paths from s to t
  #
  #   nodes = (1..7).map { |id| nodes << Node.new(id) }
  #   edges = []
  #   edges << Edge.new(nodes[0], nodes[1])
  #   edges << Edge.new(nodes[1], nodes[2])
  #   edges << Edge.new(nodes[2], nodes[3])
  #   edges << Edge.new(nodes[0], nodes[4])
  #   edges << Edge.new(nodes[1], nodes[5])
  #   edges << Edge.new(nodes[4], nodes[5])
  #   edges << Edge.new(nodes[5], nodes[6])
  #   graph = Graph.new(nodes, edges)
  #   
  #   SocialNetworkAnalyser.betweenness_centrality(graph) #=> {5=>1.0, 6=>6.0, 1=>0.0, 7=>0.0, 2=>3.0, 3=>3.0, 4=>0.0}
  # TODO check if it works fine
  def self.betweenness_centrality(graph)
    betweenness = {}
    node_ids = graph.nodes.keys
    node_ids.each do |n_id|
      betweenness[n_id] = 0.0
    end
    node_ids.each do |s_id|
      stack = []
      p = {}
      q = {}
      d = {}
      node_ids.each do |w_id|
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
        graph.edges.values.select { |e| e.v_start.id == v_id }.map { |e| e.v_end.id }.each do |w_id|
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

      fi = {}
      node_ids.each do |n_id|
        fi[n_id] = 0.0
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
    betweenness
  end

  # Computes betweenness centrality for edge. The same as above but with edge.
  def self.edge_betweenness_centrality(graph)
    betweenness = betweenness_centrality(graph)
    edge_betweenness = {}
    graph.edges.values.each { |e| edge_betweenness[e.id] = betweenness[e.v_start.id] + betweenness[e.v_end.id] }
    edge_betweenness
  end

  # Computes closeness centrality according to equation
  #   closeness_centrality(x) = 1/(d(x,t1) + ... + d(x,tn))
  #
  #   where
  #   d(x,y) is the shortest distance from x to y
  #
  #   nodes = (1..5).map { |id| Node.new(id) }
  #   edges = []
  #   edges << Edge.new(nodes[0], nodes[1])
  #   edges << Edge.new(nodes[0], nodes[2])
  #   edges << Edge.new(nodes[2], nodes[3])
  #   edges << Edge.new(nodes[3], nodes[4])
  #   graph = Graph.new(nodes, edges)
  #
  #   SocialNetworkAnalyser.closeness_centrality(graph, nodes[0].id) #=> 1.0/7
  def self.closeness_centrality(graph, src_id)
    1.0/Algorithms.dijkstra(graph, src_id).values.inject(0) { |sum, d| sum+d }
  end

  # Computes graph centrality according to equation
  #   graph_centrality(x) = 1/max(d(x,t1),...,d(x,tn))
  #
  #   where
  #   d(x,y) is the shortest distance from x to y
  #
  #   nodes = (1..5).map { |id| Node.new(id) }
  #   edges = []
  #   edges << Edge.new(nodes[0], nodes[1])
  #   edges << Edge.new(nodes[0], nodes[2])
  #   edges << Edge.new(nodes[2], nodes[3])
  #   edges << Edge.new(nodes[3], nodes[4])
  #   graph = Graph.new(nodes, edges)
  #
  #   SocialNetworkAnalyser.graph_centrality(graph, nodes[0].id) #=> 1.0/3
  def self.graph_centrality(graph, src_id)
    1.0/Algorithms.dijkstra(graph, src_id).values.max
  end

  # Detects commuties depends on given community definition. Returns given graph with subgraphs in it.
  #   nodes = (0..4).map { |id| Node.new(id) }
  #   edges = []
  #   nodes[0..2].each do |n1|
  #     nodes[3..4].each do |n2|
  #       edges << Edge.new(n1, n2)
  #     end
  #   end
  #   graph = Graph.new(nodes, edges)
  #
  #   SocialNetworkAnalyser.detect_communities(graph, :weak_community) #=> graph
  def self.detect_communities(graph, community_definition_sym)
    graph = graph.dup
    return graph if graph.edges.empty?
    
    edge_betweenness = edge_betweenness_centrality(graph)
    max_betweenness = edge_betweenness.max { |a,b| a[1] <=> b[1] }.last

    deleted_edges = []
    graph.edges.delete_if do |e_id, e|
      deleted_edges << e if edge_betweenness[e_id] == max_betweenness
      edge_betweenness[e_id] == max_betweenness
    end

    subgraphs = []
    deleted_edges.each do |edge|
      # increment out of subgraph degree
      edge.v_start.k_out += 1
      edge.v_end.k_out += 1

      [edge.v_start.id, edge.v_end.id].each do |node_id|
        if (subgraph = create_subgraph(graph, node_id)) && !subgraphs.include?(subgraph)
          subgraphs << subgraph
        end
      end
    end

    if subgraphs.count { |s| s.send(:"#{community_definition_sym.to_s}?") } >= 2
      subgraphs.each do |subgraph|
        subgraph.nodes.each do |n_id, n|
          graph.nodes.delete(n_id)
        end
        subgraph.edges.each do |e_id, e|
          graph.edges.delete(e_id)
        end
        graph.add_subgraph(subgraph)
      end

      subgraphs.each do |subgraph|
        detect_communities(subgraph, community_definition_sym)
      end
    else
      detect_communities(graph, community_definition_sym)
    end
    graph
  end

  protected

  def self.create_subgraph(graph, node_id)
    dist = Algorithms.dijkstra(graph, node_id)
    if dist.values.include?(Algorithms::Infinity)
      nodes = []
      dist.each do |n_id, d|
        if d < Algorithms::Infinity
          nodes << graph.nodes[n_id]
        end
      end
      nodes_ids = nodes.map { |n| n.id }
      edges = graph.edges.values.select { |e| e.v_end.id; nodes_ids.include?(e.v_start.id) && nodes_ids.include?(e.v_end.id) }
      Graph.new(nodes, edges)
    else
      false
    end
  end
end