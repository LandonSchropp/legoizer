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
end
