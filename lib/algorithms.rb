class Algorithms
  Infinity = 1.0/0

  # Returns hash with distance of the shortest paths to every node from given source.
  #   g = Graph.new([1,2,3,4,5], [[1,2,1],[1,3,2],[3,4,3],[4,5,4]])
  #   Algorithms.dijkstra(g, 1) #=> { 1=>0, 2=>1, 3=>2, 4=>5, 5=>9 }
  def self.dijkstra(graph, src_id)
    dist = {}
    graph.nodes.each do |n|
      dist[n.id] = Infinity
    end
    dist[src_id] = 0
    # all nodes in the graph are unoptimized - thus are in queue
    queue = graph.nodes.map { |n| n.id }
    while !queue.empty?
      # vertex in queue with the smallest distance
      u = dist.select { |k,v| queue.include?(k) }.min { |a,b| a[1] <=> b[1] }.first
      if dist[u] == Infinity
        # all remaining vertices are inaccessible from source
        break
      end
      queue.delete(u)
      # for all v neighbours of u which has not yet been removed from queue
      graph.edges.select { |e| e.v_start == u && queue.include?(e.v_end) }.map { |e| e.v_end }.each do |v|
        alt = dist[u] + graph.edges.select { |e| e.v_start == u && e.v_end == v }.first.weight
        # relax
        dist[v] = alt if alt<dist[v]
      end
    end
    dist
  end
end
