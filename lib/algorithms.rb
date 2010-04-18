class Algorithms
  Infinity = 1.0/0

  # Returns hash with distance of the shortest paths to every node from given source.
  #   nodes = (1..5).map { |id| Node.new(id) }
  #   edges = []
  #   edges << Edge.new(nodes[0], nodes[1], 1)
  #   edges << Edge.new(nodes[0], nodes[2], 2)
  #   edges << Edge.new(nodes[2], nodes[3], 3)
  #   edges << Edge.new(nodes[3], nodes[4], 4)
  #   graph = Graph.new(nodes, edges)
  #   
  #   Algorithms.dijkstra(graph, nodes[0].id).should #=> { 1=>0, 2=>1, 3=>2, 4=>5, 5=>9 }
  def self.dijkstra(graph, src_id)
    dist = {}
    graph.nodes.keys.each do |n_id|
      dist[n_id] = Infinity
    end
    dist[src_id] = 0
    # all nodes in the graph are unoptimized - thus are in queue
    queue = graph.nodes.keys.dup
    while !queue.empty?
      # vertex in queue with the smallest distance
      u = dist.select { |k,v| queue.include?(k) }.min { |a,b| a[1] <=> b[1] }.first
      if dist[u] == Infinity
        # all remaining vertices are inaccessible from source
        break
      end
      queue.delete(u)
      # for all v neighbours of u which has not yet been removed from queue
      graph.edges.values.select { |e| e.v_start.id == u && queue.include?(e.v_end.id) }.map { |e| e.v_end.id }.each do |v|
        alt = dist[u] + graph.edges.values.select { |e| e.v_start.id == u && e.v_end.id == v }.first.weight
        # relax
        dist[v] = alt if alt<dist[v]
      end
    end
    dist
  end
end
