require "chunky_png"
require "mini_magick"

require_relative "color"
require_relative "lego_blueprint"
require_relative "image"

def exit_with_error
  puts "Usage: ruby legoizer.rb <path-to-image> <width-in-millimeters> <draw-outlines>"
  exit 1
end

def is_float?(string)
  true if Float(string) rescue false
end

def is_boolean?(string)
  ["true", "false"].include? string
end

# Ensure the correct number of arguments are provided, and that the arguments are valid.
exit_with_error unless ARGV.length == 3
exit_with_error unless File.exist?(ARGV[0]) && File.file?(ARGV[0])
exit_with_error unless is_float? ARGV[1]
exit_with_error unless is_boolean? ARGV[2]

BRICK_MILLIMETER_WIDTH = 8.0
BRICK_MILLIMETER_HEIGHT = 9.6

image_path = ARGV[0]
image_width = ARGV[1].to_f
draw_outlines = ARGV[2] == "true"

# Read the image
image = Image.read(image_path)

# Determine the number of Legos to use
blueprint_width = (image_width / BRICK_MILLIMETER_WIDTH).round
blueprint_height = (image_width / image.width * image.height / BRICK_MILLIMETER_HEIGHT).round

# Convert the image to a 2D array of colors by resizing the image so each pixel represents a block
# in the blueprint.
image.scale(blueprint_width, blueprint_height)
colors = image.to_a

# Output the blueprint.
LegoBlueprint
  .new(blueprint_width, blueprint_height, colors)
  .to_chunky_png(outline: draw_outlines)
  .save('lego.png', interlace: true)
