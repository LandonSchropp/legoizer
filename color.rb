require 'color_difference'

class Color

  attr_reader :name, :id, :red, :green, :blue, :alpha

  def initialize(name: nil, id: nil, red:, green:, blue:, alpha: 0xff)
    @name = name
    @id = id
    @red = red
    @green = green
    @blue = blue
    @alpha = alpha
  end

  def to_s
    "##{ to_a.map { |n| n.to_s(16).rjust(2, "0") }.join }"
  end

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
  # completely transprent, this function instead returns the `TRANSPARENT` color.
  def closest(colors)
    return TRANSPARENT if alpha == 0
    colors.min_by { |color| color.difference(self) }
  end

  TRANSPARENT = Color.new(red: 0xff, green: 0xff, blue: 0xff, alpha: 0)
end
