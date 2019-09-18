require "gosu"
require_relative 'map'
require_relative 'player'
require 'time'

WIDTH, HEIGHT = 1024, 768

module ZOrder
  BACKGROUND, STARS, PLAYER, UI = *0..3
end

class Game < (Gosu::Window)
  def initialize
    super WIDTH, HEIGHT
    self.caption = "Milk pool"
    @map = Map.new
    @camera_x = 0
    @camera_y = -50 # Tiene que estar un poco mas arriba que nuestros elemetos de fondo
    @background_image = Gosu::Image.new("media/Fondo3.jpg")
    @player = Player.new(0,660) #CALCULAR MEJOR EL NUMERO
    @pressing = false
    @last_pressing_time = Time.now
  end

  def draw
    @background_image.draw(0, 0, ZOrder::BACKGROUND)
    @player.draw
    # Mueve la camara
    Gosu.translate(-@camera_x, -@camera_y) do
      @map.draw
    end
  end

  def update

    press_key = false

    if key_down?(Gosu::KB_RIGHT, Gosu::GP_RIGHT) && !@pressing
      @player.addCoin
      press_key = true
      @pressing = true
      @last_pressing_time = Time.now
    end

    unless press_key
      @player.removeCoin(Time.now - @last_pressing_time)
    end

    if key_down?(Gosu::KB_SPACE, Gosu::KB_SPACE) #&& @map.can_jump?(@player)
      @player.prepare_jump
    end

    current_position = @player.update
    @camera_x = @map.nextPosition(@camera_x) if @map.can_move_camera?(current_position)
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    else
      super
    end
  end

  private

    def key_down?(gp, key)
      Gosu.button_down? key or Gosu.button_down? gp
    end

    def button_up(id)
      super id
      @pressing = id != Gosu::KB_RIGHT
    end

    def key_down?(gp, key)
      Gosu.button_down? key or Gosu.button_down? gp
    end
end

Game.new.show if __FILE__ == $0