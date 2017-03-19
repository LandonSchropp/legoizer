require 'color_difference'

class Color
  attr_reader :red, :green, :blue

  def initialize(red, green, blue)
    @red = red
    @green = green
    @blue = blue
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
end
