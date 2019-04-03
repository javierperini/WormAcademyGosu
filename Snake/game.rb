require "gosu"
require_relative 'snake'
require_relative 'direction'
require_relative 'coin'

module ZOrder
  BACKGROUND, STARS, PLAYER, UI = *0..3
end

class Game < (Gosu::Window)
  def initialize
    super 640, 480
    self.caption = "Snake"
    @background_image = Gosu::Image.new("media/background.jpg",tileable: true)
    @snake = Snake.new(self.width/2, self.height/2)
    @coins = [build_coin]
  end

  def draw
    @background_image.draw(0, 0, ZOrder::BACKGROUND)
    @snake.draw
    @coins.each { |coin| coin.draw }
  end

  def update
    # pregunta si puede mover para la derecha
    can_move_direction(Gosu::KB_RIGHT, Gosu::GP_RIGHT, Direction::RIGHT)

    # pregunta si puede mover para la izquierda
    can_move_direction(Gosu::KB_LEFT, Gosu::GP_LEFT, Direction::LEFT)

    # pregunta si puede mover para abajo
    can_move_direction(Gosu::KB_DOWN, Gosu::GP_DOWN, Direction::DOWN)

    # pregunta si puede mover para arriba
    can_move_direction(Gosu::KB_UP, Gosu::GP_UP, Direction::UP)

    @snake.move(self)
    @snake.eat(@coins)

    @coins.push(build_coin) if @coins.empty?
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    else
      super
    end
  end

  private

  def build_coin
    Coin.new(self.width / 2, self.height / 2)
  end

  def can_move_direction(key, gp, direction)
    @snake.change_direction(Direction.build_direction(direction)) if key_down?(gp, key)
  end

  def key_down?(gp, key)
    Gosu.button_down? key or Gosu.button_down? gp
  end
end

Game.new.show if __FILE__ == $0