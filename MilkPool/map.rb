module Tiles
  Grass = 0
  Water = 8
  Block = 12
end

class Map
  attr_reader :width, :height, :exceed

  def initialize
    @square = 80
    @tileset = Gosu::Image.load_tiles("media/milkPoolFloor.png", @square, @square, tileable: true)
    @lines = File.readlines("media/milkPoolMap.txt").map { |line| line.chomp }

    @height = @lines.size # alto
    @width = @lines[0].size # El ancho de la matris
    @tiles = buildMap
    @exceed = false
  end

  def half_screen
    512
  end

  def can_move_camera?(position, camera)
    position >= half_screen &&  camera < 2500
  end

  def draw
    @height.times do |y|
      @width.times do |x|
        tile = @tiles[y][x]
        drawTile(tile, x, y) if tile
      end
    end
  end

  def prevPosition(camera_x)
    diff = camera_x - 50
    exceedStartMap(diff) ? 0 : diff
  end

  def nextPosition(camera_x)
    diff = camera_x + 50
    @exceed = true
    diff
  end

  def can_jump?(player, camera)
    tile = get_ground_tile(player, camera)
    !tile.nil? and tile == Tiles::Block
  end

  def on_water?(player, camera)
    tile = get_ground_tile(player, camera)
    !tile.nil? and tile == Tiles::Water
  end

  def get_ground_tile(player, camera)
    x = player.x.round
    select_tile = ((x + camera)/@square).round
    @tiles[8][select_tile]
  end

  def endMapToPixel
    @width * 56 # Averiguar de donde sale 56
  end

  private

  def drawTile(tile, x, y)
    image = @tileset[tile]
    image.draw(x * @square + 1, y * @square + 1, 1)
  end

  def exceedEndMap(camera_x)
    camera_x > endMapToPixel
  end

  def exceedStartMap(camera_x)
    camera_x <= 0
  end

  def buildMap
    Array.new(@height) do |y|
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
end