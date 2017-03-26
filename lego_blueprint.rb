require "chunky_png"
require "yaml"

require_relative "color"

# An immutable representation of a grid of legos.
class LegoBlueprint

  # Lego constants
  BRICK_PIXEL_WIDTH = 10
  BRICK_PIXEL_HEIGHT = 12

  # Load the Lego brick colors into a constant.
  BRICK_COLORS = YAML.load(IO.read(File.join(File.dirname(__FILE__), 'colors.yml'))).map do |hash|
    Color.new(**hash)
  end

  attr_reader :width, :height, :colors

  def initialize(width, height, colors)
    @width = width
    @height = height
    @colors = colors.map { |row| row.map { |color| color.closest(BRICK_COLORS) } }
  end

  def to_chunky_png(outline: false)
    image_width = colors.length * BRICK_PIXEL_WIDTH
    image_height = colors.first.length * BRICK_PIXEL_HEIGHT

    blueprint = ChunkyPNG::Image.new(image_width, image_height, ChunkyPNG::Color::TRANSPARENT)

    image_width.times do |x|
      image_height.times do |y|
        next if outline && x % BRICK_PIXEL_WIDTH == 0 && y % BRICK_PIXEL_WIDTH == 0
        color = colors[x / BRICK_PIXEL_WIDTH][y / BRICK_PIXEL_HEIGHT]
        blueprint[x, y] = ChunkyPNG::Color.rgba(*color.to_a)
      end
    end

    blueprint
  end
end
