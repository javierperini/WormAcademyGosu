require "gosu"

module ZOrder
  BACKGROUND, STARS, PLAYER, UI = *0..3
end

class Coin
  attr_reader :x, :y

  def initialize(init_x, init_y)
    @image = Gosu::Image.new("media/coin.png")
    @x = rand * init_x
    @y = rand * init_y
    @angle = 0.0
  end

  def draw
    @image.draw_rot(@x, @y, ZOrder::BACKGROUND, @angle)
  end
end