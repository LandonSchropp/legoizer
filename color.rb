require 'color_difference'

class Color
  attr_reader :red, :green, :blue, :alpha

  def initialize(red, green, blue, alpha)
    @red = red
    @green = green
    @blue = blue
    @alpha = alpha
  end

  def self.from_hex(hex)
    hex = hex.gsub(/[^0-9a-f]/, "")
    Color.new(hex[0..1].to_i(16), hex[2..3].to_i(16), hex[4..5].to_i(16), 0xff)
  end

  def to_s
    "##{ to_a.map { |n| n.to_s(16).rjust(2, "0") }.join }"
  end

  alias_method :inspect, :to_s

  def to_h
    { r: red, g: green, b: blue, a: alpha }
  end

  def to_a
    [red, green, blue, alpha]
  end

  # Returns a number representing the *visual* differnece between two colors.
  def difference(color)
    ColorDifference.cie2000(to_h, color.to_h)
  end

  # Returns the closest color in the provided array of colors to this color. If the color is
  # completely transprent, this function returns white
  def closest(colors)
    return OFF_WHITE if alpha == 0
    colors.min_by { |color| color.difference(self) }
  end

  OFF_WHITE = Color.from_hex("#fafafaff")
end
