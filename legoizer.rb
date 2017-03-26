require "chunky_png"
require "mini_magick"

require_relative "color"
require_relative "lego_blueprint"
require_relative "image"

def exit_with_error
  puts "Usage: ruby legoizer.rb <path-to-image> <block-width> <draw-outlines>"
  exit 1
end

def is_int?(string)
  true if Integer(string) rescue false
end

def is_boolean?(string)
  ["true", "false"].include? string
end

# Ensure the correct number of arguments are provided, and that the arguments are valid.
exit_with_error unless ARGV.length == 3
exit_with_error unless File.exist?(ARGV[0]) && File.file?(ARGV[0])
exit_with_error unless is_int? ARGV[1]
exit_with_error unless is_boolean? ARGV[2]

image_path = ARGV[0]
blueprint_width = ARGV[1].to_i
draw_outlines = ARGV[2] == "true"

# Read the image
image = Image.read(image_path)

# Determine the blueprint's height using the ratio of the image's width to its height and the ratio
# of the block sizes.
block_apsect_ratio = 1.0 * LegoBlueprint::BRICK_PIXEL_WIDTH / LegoBlueprint::BRICK_PIXEL_HEIGHT
image_aspect_ratio = 1.0 * image.width / image.height
blueprint_height = (1.0 * blueprint_width / image_aspect_ratio * block_apsect_ratio).round

# Convert the image to a 2D array of colors by resizing the image so each pixel represents a block
# in the blueprint.
image.scale(blueprint_width, blueprint_height)
colors = image.to_a

# Output the blueprint.
LegoBlueprint
  .new(blueprint_width, blueprint_height, colors)
  .to_chunky_png(outline: draw_outlines)
  .save('lego.png', interlace: true)
