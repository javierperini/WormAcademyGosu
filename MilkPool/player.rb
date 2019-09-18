require_relative 'move_state'

class Player
  # 32 x 32
  attr_accessor :x, :y, :tileset, :coin, :ground_position

  def initialize(x, y)
    @tile_size = 32
    @x, @y = x, y
    @ground_position = y
    @current_state = Standing.new(self)
    @tileset = Gosu::Image.load_tiles("media/sprite.png", @tile_size,  @tile_size, tileable: true)
    @coin = 0
  end

  def draw
    @current_state.draw
  end

  def update
    @current_state = @current_state.next_state
    @current_state.update(@x + @coin)
  end

  def addCoin
    @coin += 6 if @coin <= 16
  end

  def removeCoin(tick_diff)
    @coin -= 0.7 if @coin > 0
  end

  def prepare_jump
    @current_state.prepare_jump
  end
end