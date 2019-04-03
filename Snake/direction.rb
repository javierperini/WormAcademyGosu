class Direction
  UP = 'UP'
  DOWN = 'DOWN'
  LEFT = 'LEFT'
  RIGHT = 'RIGHT'

  def self.build_direction(direction)
    klass = {UP: Vertical, DOWN: Vertical, LEFT: Horizontal, RIGHT: Horizontal }
    klass[direction.to_sym].new(direction)
  end

  def initialize(direction)
    @direction = direction
  end

  def change_direction(current_direction)
    orientation?(current_direction) ? current_direction : @direction
  end
end

class Horizontal < Direction
  def orientation?(current_direction)
    current_direction == LEFT || current_direction == RIGHT
  end
end

class Vertical < Direction
  def orientation?(current_direction)
    current_direction == UP || current_direction == DOWN
  end
end