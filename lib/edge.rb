class Edge
  attr_accessor :v_start, :v_end, :weight
  
  def initialize(v_start, v_end, weight=1)
    self.v_start = v_start
    self.v_end = v_end
    self.weight = weight
  end
end
