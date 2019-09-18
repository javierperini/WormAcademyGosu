
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
  def initialize(player)
    super(player)
    calculateJumpPosition
    @running_tiles = build_running_tiles(@ticks)
  end

  def calculateJumpPosition
    xi = @player.x
    xf = @player.x + 100
    step_size = 1
    @jumpPositions = (xi..xf).step(step_size).inject([]) { |memo, x| memo << [x, @player.ground_position + calc_y_position(x, xi, xf)]}
  end

  def calc_y_position(x, xi, xf)
    x * x - xf * x - xi * x + xi * xf
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