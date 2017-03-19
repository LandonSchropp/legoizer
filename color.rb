require 'color_difference'

class Color
  attr_reader :red, :green, :blue

  def initialize(red, green, blue)
    @red = red
    @green = green
    @blue = blue
  end

  def self.from_hex(hex)
    hex = hex.gsub(/[^0-9a-f]/, "")
    Color.new(hex[0..1].to_i(16), hex[2..3].to_i(16), hex[4..5].to_i(16))
  end

  def to_s
    "##{ red.to_s(16) }#{ green.to_s(16) }#{ blue.to_s(16) }"
  end

  alias_method :inspect, :to_s

  # Returns a number representing the *visual* differnece between two colors.
  def difference(color)
    ColorDifference.cie2000(to_h, color.to_h)
  end

  def to_h
    { r: red, g: green, b: blue }
  end

  def to_a
    [red, green, blue]
  end
end
