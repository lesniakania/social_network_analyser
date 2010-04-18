class Node
  attr_accessor :id, :k_out

  def initialize(id)
    self.id = id
    self.k_out = 0
  end

  def to_s
    self.id.to_s
  end
end
