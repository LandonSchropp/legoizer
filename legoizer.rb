require "chunky_png"
require "mini_magick"

require_relative "color"
require_relative "lego_blueprint"

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

# Read in the image
image = MiniMagick::Image.open(image_path)

# Determine the number of Legos to use
image_brick_width = (image_width / BRICK_MILLIMETER_WIDTH).round
image_brick_height = (image_width / image.width * image.height / BRICK_MILLIMETER_HEIGHT).round

# Resize the image to the correct number of pixels and read it into a color array
image.scale "#{ image_brick_width }x#{ image_brick_height }!"

# Use ChunkyPNG to read the image pixel by pixel
image.format "png"
chunky_image = ChunkyPNG::Image.from_io(StringIO.new(image.to_blob))

# Convert the image to a 2D array of colors
lego_colors = (0...chunky_image.width).map do |x|
  (0...chunky_image.height).map do |y|

    red = (chunky_image[x, y] & 0xff000000) >> 24
    green = (chunky_image[x, y] & 0x00ff0000) >> 16
    blue = (chunky_image[x, y] & 0x0000ff00) >> 8
    alpha = (chunky_image[x, y] & 0x000000ff)

    Color.new(red: red, green: green, blue: blue, alpha: alpha)
  end
end

# Output the blueprint.
LegoBlueprint
  .new(image_brick_width, image_brick_height, lego_colors)
  .to_chunky_png(outline: draw_outlines)
  .save('lego.png', interlace: true)
