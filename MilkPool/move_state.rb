require 'nmatrix'

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

class PlayerState
  def initialize(player)
    @player = player
    @ticks = 60
    @factor = 3.0
  end

  def update(_)
    @player.x
  end

  def draw
    getImage.draw(@player.x, @player.y, 2)
  end

  def prepare_jump
  end
end

class Standing < PlayerState
   def initialize(player)
     super(player)
     @standing_tiles = build_blink_tiles(@ticks)
   end

  def next_state
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

  def next_state
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

  def update(move_x)
    @player.x = move_x
    @player.x
  end

  def next_state
    return Jumping.new(@player) if @player.y == (@player.ground_position - 1)
    return self if @player.coin > 0 and @player.coin < 17
    return Standing.new(@player)
  end

  def build_running_tiles(ticks)
    third_part = (ticks / 3)
    [Move::RUN_1] * third_part + [Move::RUN_2] * third_part + [Move::RUN_3] * third_part
  end

  def getImage
    @player.tileset[@running_tiles.rotate!.first]
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

  def next_state
    return self if !@jumpPositions.empty?
    return Running.new(@player)
  end

  def update(_)
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