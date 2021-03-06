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

  def can_move?
    @current_state.can_move?
  end

  def build_text(game)
    @current_state.text(game)
  end

  def win?(camera, map)
    @current_state.win?(camera, map)
  end

  def update(map, camera)
    @current_state = @current_state.next_state(map, camera)
    @current_state.update(@x + @coin, map, camera)
  end

  def addCoin
    @coin += 5 if @coin <= 20
  end

  def removeCoin
    @coin -= 0.5 if @coin > 0
  end

  def prepare_jump
    @current_state.prepare_jump
  end
end