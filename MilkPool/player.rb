module Move
  STANDING = 0
  STANDING_2 = 1
  PREPARE_RUN = 2
  RUN_1 = 3
  RUN_2 = 4
  RUN_3 = 5
  JUMP = 120
end

module State
  STANDING = 0
  RUNNING = 1
  JUMPING = 2
end

class Player
  # 32 x 32

  def initialize(x, y)
    @tile_size = 32
    @x, @y = x, y
    @prev_x, prev_y = x, y
    @tileset = Gosu::Image.load_tiles("media/sprite.png", @tile_size,  @tile_size, tileable: true)
    ticks = 60
    @standing_tiles = build_blink_tiles(ticks)
    @running_tiles = build_running_tiles(ticks)
    @current_state = State::STANDING
    @prev_state = State::STANDING
    @coin = 0
  end

  def draw
    # NUMEROS INVENTADOS
    build_current_image.draw(@x, @y, 2)
  end

  def move_right
    diff = @x + @coin
    half_screen = 1024 / 2
    (diff >= half_screen).tap do |surpass_half_screen|
      update(diff) unless surpass_half_screen
    end
  end

  def addCoin
    @coin += 4 if @coin <= 16
  end

  def removeCoin(tick_diff)
    @coin -= 1 if @coin > 0
    @current_state = State::STANDING if tick_diff > 2.0
  end

  def move_left
    @x -= 10
  end

  def update(move_x)
    @prev_x, @x = @x, move_x
    @prev_state = @current_state
    @current_state = State::RUNNING unless @prev_x == @x
  end

  private

  def build_current_image
    images_condition = [
        [@coin <= 0 && @current_state == State::STANDING, -> { @tileset[@standing_tiles.rotate!.first]}],
        [@prev_state == State::STANDING, -> { @tileset[Move::PREPARE_RUN] }],
        [@prev_state == State::RUNNING, -> { @tileset[@running_tiles.rotate!.first] }]
    ]
    images_condition.find {|x| x[0]}.last.call
  end

  def build_blink_tiles(ticks)
    [Move::STANDING] * ticks * 3 +  [Move::STANDING_2] * (ticks / 3)
  end

  def build_running_tiles(ticks)
    third_part = (ticks / 3)
    [Move::RUN_1] * third_part + [Move::RUN_2] * third_part + [Move::RUN_3] * third_part
  end
end