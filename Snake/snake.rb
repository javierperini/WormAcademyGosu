require "gosu"
require_relative 'direction'

module ZOrder
  BACKGROUND, STARS, PLAYER, UI = *0..3
end

class Snake

  def initialize(init_x, init_y)
    @body = []
    (0..10).each do|x|
      @body.push(body_part(init_x + x, init_y))
    end
    
    @x = init_x
    @y = init_y
    @vel = 1.5
    @vel_x = @vel_y = 0.0
    @large = 1
    @direction = Direction::RIGHT
  end

  def draw
    init_previous_x = @x
    init_previous_y = @y
    @body.each { |current_body| init_previous_x, init_previous_y = draw_body(current_body, init_previous_x, init_previous_y) }
  end

  def body_part(init_x, init_y)
    BodyPart.new(init_x, init_y)
  end

  def eat(coins)
    initSize = coins.size
    coins.reject! {|coin| Gosu.distance(@x, @y, coin.x, coin.y) < 7 }
    can_grow_up = coins.size < initSize;
    grow_up if can_grow_up
  end

  def move(game)
    dic = {
        LEFT:  -> { @x < 0 ? @x = game.width : @x-= @vel},
        RIGHT: -> { @x > game.width ? @x = 0 : @x+= @vel},
        UP: -> { @y < 0 ? @y = game.height : @y-= @vel},
        DOWN: -> { @y > game.height ? @y = 0 : @y+= @vel}
    }
    dic[@direction.to_sym].call
  end

  def change_direction(next_direction)
    @direction = next_direction.change_direction(@direction)
  end

  def grow_up
    @vel += 0.5
    @body.push(body_part(@x, @y))
  end

  private

  def draw_body(current_body, x, y)

    previous_x = current_body.x
    previous_y = current_body.y

    current_body.set_position(x, y)
    current_body.draw

    return previous_x, previous_y
  end
end

class BodyPart
  attr_reader :x, :y

  def initialize(init_x, init_y)
    @image = Gosu::Image.new("media/red_snake.jpg")
    @x = init_x
    @y = init_y
    @angle = 0.0
  end

  def draw
    @image.draw_rot(@x, @y, ZOrder::BACKGROUND, @angle)
  end

  def set_position(x, y)
    @x = x
    @y = y
  end
end
