require "gosu"
require_relative 'map'
WIDTH, HEIGHT = 640, 480

module ZOrder
  BACKGROUND, STARS, PLAYER, UI = *0..3
end

class Game < (Gosu::Window)
  def initialize
    super 640, 480
    self.caption = "Milk pool"
    @map = Map.new
    # The scrolling position is stored as top left corner of the screen.
    @camera_x = @camera_y = 0
  end

  def draw
    #@background_image.draw(0, 0, ZOrder::BACKGROUND)
    Gosu.translate(-@camera_x, -@camera_y) do
      @map.draw
    end
  end

  def update
    @camera_x = @map.width * 50 - WIDTH
    @camera_y = @map.height * 50 - HEIGHT
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
end

Game.new.show if __FILE__ == $0