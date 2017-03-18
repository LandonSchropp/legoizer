require "mini_magick"
require "yaml"

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
BRICK_COLORS = yaml["colors"]

# Read in the image
image = MiniMagick::Image.open(IMAGE_PATH)

# Determine the number of Legos to use
image_brick_width = (IMAGE_WIDTH / BRICK_SIZE["width"]).round
image_brick_height = (IMAGE_WIDTH / image.width * image.height / BRICK_SIZE["height"]).round

# Resize the image to the correct number of pixels and read it into a color array
image.resize("#{ image_brick_width }x#{ image_brick_height }")

# Output the image
image.format "png"
image.write "lego.png"
