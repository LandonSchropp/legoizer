def exit_with_error
  puts "Usage: ruby legoizer.rb <path-to-image> <width-in-inches>"
  exit 1
end

def is_float?(string)
  true if Float(string) rescue false
end

# Ensure the correct number of arguments are provided, and that the arguments are valid.
IMAGE_PATH, IMAGE_WIDTH = ARGV
exit_with_error unless ARGV.length == 2
exit_with_error unless File.exist?(IMAGE_PATH) && File.file?(IMAGE_PATH)
exit_with_error unless is_float? IMAGE_WIDTH
