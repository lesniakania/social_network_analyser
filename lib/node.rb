class Node
  attr_accessor :id

  def initialize(id)
    self.id = id
  end

  def to_s
    self.id.to_s
  end
end
