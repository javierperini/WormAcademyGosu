require "gosu"
require_relative 'map'
require_relative 'player'
require_relative 'stage'
require 'time'

WIDTH, HEIGHT = 1024, 768

class Game < (Gosu::Window)
  def initialize
    super WIDTH, HEIGHT
    self.caption = "Milk pool"
    @player = Player.new(0,660) #CALCULAR MEJOR EL NUMERO
    @current_stage = InitStage.new(@player, self)
  end

  def draw
    @current_stage.draw
  end

  def update
    @current_stage = @current_stage.next_stage
    press_right = key_down?(Gosu::KB_RIGHT, Gosu::GP_RIGHT)
    press_space = key_down?(Gosu::KB_SPACE, Gosu::KB_SPACE)
    @current_stage.update(press_right, press_space)
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    else
      super
    end
  end

  def button_up(id)
    super id
    @current_stage.pressing = id != Gosu::KB_RIGHT
  end

  def key_down?(gp, key)
    Gosu.button_down? key or Gosu.button_down? gp
  end
end

Game.new.show if __FILE__ == $0