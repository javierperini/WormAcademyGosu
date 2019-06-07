require "gosu"
require_relative 'map'
WIDTH, HEIGHT = 640, 480

module ZOrder
  BACKGROUND, STARS, PLAYER, UI = *0..3
end

class Game < (Gosu::Window)
  def initialize
    super 1024,768
    self.caption = "Milk pool"
    @map = Map.new
    # The scrolling position is stored as top left corner of the screen.
    @camera_x = @camera_y = 0

    @camera_x = @map.width * 50 - WIDTH
    @camera_y = @map.height * 50 - HEIGHT
  end

  def draw
    #@background_image.draw(0, 0, ZOrder::BACKGROUND)
    Gosu.translate(-@camera_x, -@camera_y) do
      @map.draw
    end
  end

  def update


    if key_down?(Gosu::KB_UP, Gosu::GP_UP)

    end
    if key_down?(Gosu::KB_DOWN, Gosu::GP_DOWN)
    end

    if key_down?(Gosu::KB_LEFT, Gosu::GP_LEFT)
      @camera_x = @map.prevPosition(@camera_x)
    end

    if key_down?(Gosu::KB_RIGHT, Gosu::GP_RIGHT)
      @camera_x = @map.nextPosition(@camera_x)
    end
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

    def can_move_direction(key, gp)

    end

    def key_down?(gp, key)
      Gosu.button_down? key or Gosu.button_down? gp
    end
end

Game.new.show if __FILE__ == $0