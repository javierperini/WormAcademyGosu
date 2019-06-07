module Tiles
  Grass = 0
  Water = 3
  Block = 2
end

class Map
  attr_reader :width, :height

  def initialize
    # Load 60x60 tiles, 5px overlap in all four directions.
    @tileset = Gosu::Image.load_tiles("media/milkPoolFloor.png", 80, 80, tileable: true)

    @lines = File.readlines("media/milkPoolMap.txt").map { |line| line.chomp }
    @height = @lines.size # alto
    @width = @lines[0].size # El ancho de la matris
    @tiles = Array.new(@height) do |y|
      Array.new(@width) do |x|
        floor = @lines[y][x]
        1 if floor.nil?
        case floor
        when 'B'
          Tiles::Block
        when 'W'
          Tiles::Water
        when 'G'
          Tiles::Grass
        else
          nil
        end
      end
    end
  end

  def draw
    @height.times do |y|
      @width.times do |x|
        tile = @tiles[y][x]
        if tile
          image = @tileset[tile]
          image.draw(x * 80, y * 80, 1)
        end
      end
    end
  end

  def nextPosition(camera_x)
    camera_x -= 50
    camera_x = -self.width if camera_x.abs > self.width
    camera_x
  end

  def prevPosition(camera_x)
    camera_x += 50
    camera_x = 0 if camera_x > 0
    camera_x
  end
end