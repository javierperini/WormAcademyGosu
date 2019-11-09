require "gosu"

module ZOrder
  BACKGROUND, STARS, PLAYER, UI = *0..3
end

class Stage
  attr_accessor :pressing
  def initialize(player, game)
    @player = player
    @game = game
    @pressing = false
    @font = Gosu::Font.new(@game, "media/fonts/pixelade-webfont.ttf", 40)
  end

  def update(_,_)

  end

  def draw

  end

  def next_stage
    self
  end
end

class InitStage < Stage
  def initialize(player, game)
    super(player, game)
    @press_key = false
    @background_image = Gosu::Image.new("media/fondo4.jpg")
  end

  def update(_, press_space)
    @press_key = press_space
  end

  def draw
    @background_image.draw_rot(300, 300, ZOrder::BACKGROUND, 0)
    @font.draw_text("Toca la barra espaciadora para arrancar", 250.5, 177.5, 0, 2, 1, Gosu::Color::RED)
  end

  def next_stage
    return PlayingStage.new(@player, @game) if @press_key
    self
  end
end

class PlayingStage < Stage
  def initialize(player, game)
    super(player, game)
    @map = Map.new
    @camera_x = 0
    @camera_y = -50
    @background_image = Gosu::Image.new("media/fondo4.jpg")
    @player = Player.new(0,660) #CALCULAR MEJOR EL NUMERO
    @background_sound = Gosu::Song.new("media/sounds/backgroundsound.mp3")
    @counter = 100
  end

  def next_stage
    win = @player.win?(@camera_x, @map)
    can_move = @player.can_move?
    @counter-= 1 if !can_move
    return WinnerStage.new(@player, @game) if win && !can_move && @counter < 0
    return LoserStage.new(@player, @game) if !win && !can_move  && @counter < 0
    self
  end

  def draw
    @background_image.draw_rot(300, 300, ZOrder::BACKGROUND, 0)
    @player.draw
    @player.build_text(@game)
    # Mueve la camara
    Gosu.translate(-@camera_x, -@camera_y) do
      @map.draw
    end
  end

  def update(press_right, press_space)
    press_key = false
    if press_right && !@pressing
      @player.addCoin
      press_key = true
      @pressing = true
    end

    unless press_key
      @player.removeCoin
    end

    if press_space && @map.can_jump?(@player, @camera_x)
      @player.prepare_jump
    end

    current_position = @player.update(@map, @camera_x)
    if @map.can_move_camera?(current_position, @camera_x) && @player.can_move? && press_key
      @camera_x = @map.nextPosition(@camera_x)
    end
  end
end

class FinishStage < Stage
  def initialize(player, game)
    super(player, game)
  end

  def draw
    get_image.draw_rot(300, 300, ZOrder::BACKGROUND, 0)
    @font.draw_text(get_text, 250.5, 177.5, 0, 2, 1, Gosu::Color::RED)
  end
end


class WinnerStage < FinishStage
  def get_image
    Gosu::Image.new("media/fondo4.jpg")
  end

  def get_text
    'Ganaste capo'
  end
end

class LoserStage < FinishStage
  def get_image
    Gosu::Image.new("media/fondo4.jpg")
  end

  def get_text
    'PERDISTE capo'
  end
end