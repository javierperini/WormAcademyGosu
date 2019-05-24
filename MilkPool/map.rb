module Tiles
  Grass = 1
  Water = 2
  Block = 3
end

class Map
  attr_reader :width, :height

  def initialize
    # Load 60x60 tiles, 5px overlap in all four directions.
    @tileset = Gosu::Image.load_tiles("media/milkPoolFloor.png", 60, 60, tileable: true)

    lines = File.readlines("media/milkPoolMap.txt").map { |line| line.chomp }
    @height = lines.size
    @width = lines[0].size
    @tiles = Array.new(@width) do |x|
      Array.new(@height) do |y|
        case lines[y][x, 1]
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
        tile = @tiles[x][y]
        if tile
          # Draw the tile with an offset (tile images have some overlap)
          # Scrolling is implemented here just as in the game objects.
          @tileset[tile].draw(x * 25, y * 25, 0)
        end
      end
    end
  end
end