require "gosu"
require_relative 'direction'

module ZOrder
  BACKGROUND, STARS, PLAYER, UI = *0..3
end

class Snake

  def initialize(init_x, init_y)
    @image = Gosu::Image.new("media/red_snake.jpg")
    @x = init_x
    @y = init_y
    @vel_x = @vel_y = @angle = 0.0
    @large = 1
    @direction = Direction::RIGHT
  end

  def draw
    @image.draw_rot(@x, @y, ZOrder::BACKGROUND, @angle)
  end

  def eat(coins)
    coins.reject! {|coin| Gosu.distance(@x, @y, coin.x, coin.y) < 7 }
  end

  def move(game)
    dic = {
        LEFT:  -> { @x < 0 ? @x = game.width : @x-= 1},
        RIGHT: -> { @x > game.width ? @x = 0 : @x+= 1},
        UP: -> { @y < 0 ? @y = game.height : @y-= 1},
        DOWN: -> { @y > game.height ? @y = 0 : @y+= 1}
    }
    dic[@direction.to_sym].call
  end

  def change_direction(next_direction)
    @direction = next_direction.change_direction(@direction)
  end
end