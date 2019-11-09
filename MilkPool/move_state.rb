require 'nmatrix'
require 'gosu'

module Move
  STANDING = 0
  STANDING_2 = 1
  PREPARE_RUN = 2
  RUN_1 = 3
  RUN_2 = 4
  RUN_3 = 5
  WIN = 11
  JUMP = 120
end

module State
  STANDING = 0
  RUNNING = 1
  JUMPING = 2
  LANDING = 3
end

module Text
  WINNER_TEXT = "No me rompi la nariz!!!!!"
  LOSER_TEXT  = "Noo mi nariz esta rota!!!"
end

FONT_ASSETS = {
    font: "media/fonts/pixelade-webfont.ttf"
}

class PlayerState
  def initialize(player)
    @player = player
    @ticks = 60
    @factor = 3.0
    @played = false
  end

  def on_water?(map, camera)
    map.on_water?(@player, camera)
  end

  def update(_, _, _)
    @player.x
  end

  def draw
    getImage.draw(@player.x, @player.y, 2)
  end

  def prepare_jump
  end

  def next_state(_, _)
  end

  def win?
    false
  end

  def can_move?
    true
  end

  def text(_)

  end

  def build_text(game, text, color)
    @font = Gosu::Font.new(game, FONT_ASSETS[:font], 40)
    @font.draw_text(text, 250.5, 177.5, 0, 2, 1, color)
  end
end

class Standing < PlayerState
   def initialize(player)
     super(player)
     @standing_tiles = build_blink_tiles(@ticks)
   end

  def next_state(map, camera)
    return Sinking.new(@player) if on_water?(map, camera)
    return self if @player.coin <= 0
    return PrepareRunning.new(@player)
  end

  def build_blink_tiles(ticks)
    [Move::STANDING] * ticks * 3 +  [Move::STANDING_2] * (ticks / 3)
  end

  def getImage
    @player.tileset[@standing_tiles.rotate!.first]
  end
end

class PrepareRunning < PlayerState

  def next_state(_, _)
    return Running.new(@player)
  end

  def getImage
    @player.tileset[Move::PREPARE_RUN]
  end
end

class Running < PlayerState
  def initialize(player)
    super(player)
    @running_tiles = build_running_tiles(@ticks)
  end

  def update(move_x, map, camera)
    @player.x = move_x if !map.exceed
    @player.x
  end

  def next_state(map, camera)
    coin = @player.coin
    return Sinking.new(@player) if on_water?(map, camera)
    return Jumping.new(@player) if @player.y == (@player.ground_position - 1)
    return self if coin > 0
    return Standing.new(@player)
  end

  def build_running_tiles(ticks)
    third_part = (ticks / 3)
    [Move::RUN_1] * third_part + [Move::RUN_2] * third_part + [Move::RUN_3] * third_part
  end

  def getImage
    tile = @running_tiles.rotate!.first
    @player.tileset[tile]
  end

  def prepare_jump
    @player.y = @player.ground_position - 1
  end
end

class Jumping < PlayerState
  attr_accessor :coeff_a, :coeff_b, :coeff_c

  def initialize(player)
    super(player)
    calculate_coeffs
    calculateJumpPosition
    @running_tiles = build_running_tiles(@ticks)
  end

  def calculate_coeffs
    xi = @player.x
    xf = @player.x + [10 + (@player.coin * @factor).round, 100].min
     xm = (xf+xi) / 2.0
    h =  [(@player.coin * 15.0).round, 300].min

    coeffs =  NMatrix.new([3,3], [xi**2, xi, 1,
                                  xf**2, xf, 1,
                                  xm**2, xm, 1], dtype: :float32)

    rhs = NMatrix.new([3,1], [0, 0, h], dtype: :float32)

    solution = coeffs.solve(rhs)
    @coeff_a = solution[0]
    @coeff_b = solution[1]
    @coeff_c = solution[2]
  end

  def calculateJumpPosition
    xi = @player.x
    xf =  @player.x + [10 + (@player.coin * @factor).round, 100].min
    step_size = 0.5
     @jumpPositions = (xi..xf).step(step_size).inject([]) { |memo, x| memo << [x, @player.ground_position - calculate_y_position(xi, xf, x)]}
  end

  def calculate_y_position(xi, xf, x)
    if xi != x && xf != x
      @coeff_a * (x ** 2) + @coeff_b * x + @coeff_c
    else
      0.0
    end
  end

  def win?(camera, map)
    !camera.nil? && !map.nil? && !on_water?(map, camera)
  end

  def next_state(map, camera)
    return self if !@jumpPositions.empty?
    return Sinking.new(@player) if on_water?(map, camera)
    return Winning.new(@player) if win?(camera, map)
  end

  def update(_, _, _)
    @player.x, @player.y = @jumpPositions.shift
    @player.x
  end

  def build_running_tiles(ticks)
    third_part = (ticks / 3)
    [Move::RUN_1] * third_part + [Move::RUN_2] * third_part + [Move::RUN_3] * third_part
  end

  def getImage
    @player.tileset[@running_tiles.rotate!.first]
  end
end

class Landing < PlayerState
  def initialize(player)
    super(player)
  end

  def getImage
    @player.tileset[Move::WIN]
  end

  def drawText
  end

  def getSound
  end

  def playSong
    getSound.play
    @played = true
  end

  def draw
    playSong unless @played
    getImage.draw(@player.x, @player.y, 2)
  end

  def update(_, map, camera)
    @player.x
  end

  def next_state(map, camera)
    self
  end

  def can_move?
    false
  end
end

class Sinking < Landing
  def initialize(player)
    super(player)
  end

  def getSound
    Gosu::Song.new("media/sounds/loser.mp3")
  end

  def update(_, map, camera)
    @player.y += 1 unless @player.y > 10000
    @player.x
  end

  def text(game)
    build_text(game, Text::LOSER_TEXT, Gosu::Color::RED)
  end

  def win?
    false
  end
end

class Winning < Landing
  def initialize(player)
    super(player)
  end

  def getSound
    Gosu::Song.new("media/sounds/winner.mp3")
  end

  def text(game)
    build_text(game, Text::WINNER_TEXT, Gosu::Color::YELLOW)
  end

  def win?
    true
  end
end