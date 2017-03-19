require "chunky_png"
require "mini_magick"
require "yaml"

require_relative "color"

def exit_with_error
  puts "Usage: ruby legoizer.rb <path-to-image> <width-in-millimeters>"
  exit 1
end

def is_float?(string)
  true if Float(string) rescue false
end

# Ensure the correct number of arguments are provided, and that the arguments are valid.
exit_with_error unless ARGV.length == 2
exit_with_error unless File.exist?(ARGV[0]) && File.file?(ARGV[0])
exit_with_error unless is_float? ARGV[1]

IMAGE_PATH = ARGV[0]
IMAGE_WIDTH = ARGV[1].to_f

# Read in the configuration data
yaml = YAML.load(IO.read(File.join(File.dirname(__FILE__), 'lego.yml')))
BRICK_SIZE = yaml["size"]

# Parse the colors
BRICK_COLOR_CONFIGURATION = yaml["colors"].map do |config|
  config.merge({ "color" => Color.from_hex(config["hex"]) })
end

BRICK_COLORS = BRICK_COLOR_CONFIGURATION.map { |config| config["color"] }

# Read in the image
image = MiniMagick::Image.open(IMAGE_PATH)

# Determine the number of Legos to use
image_brick_width = (IMAGE_WIDTH / BRICK_SIZE["width"]).round
image_brick_height = (IMAGE_WIDTH / image.width * image.height / BRICK_SIZE["height"]).round

# Resize the image to the correct number of pixels and read it into a color array
image.resize "#{ image_brick_width }x#{ image_brick_height }!"

# Use ChunkyPNG to read the image pixel by pixel
image.format "png"
chunky_image = ChunkyPNG::Image.from_io(StringIO.new(image.to_blob))

# Convert the image to lego colors
lego_colors = (0...chunky_image.width).map do |x|
  (0...chunky_image.height).map do |y|

    red = (chunky_image[x, y] & 0xff000000) >> 24
    green = (chunky_image[x, y] & 0x00ff0000) >> 16
    blue = (chunky_image[x, y] & 0x0000ff00) >> 8

    Color.new(red, green, blue).closest(BRICK_COLORS)
  end
end

# Draw the image
blueprint_width = lego_colors.length * BRICK_SIZE["pixel_width"]
blueprint_height = lego_colors.first.length * BRICK_SIZE["pixel_height"]
blueprint = ChunkyPNG::Image.new(blueprint_width, blueprint_height, ChunkyPNG::Color::BLACK)

blueprint_width.times do |x|
  blueprint_height.times do |y|
    color = lego_colors[x / BRICK_SIZE["pixel_width"]][y / BRICK_SIZE["pixel_height"]]
    blueprint[x, y] = ChunkyPNG::Color.rgb(*color.to_a)
  end
end

blueprint.save('lego.png', :interlace => true)
