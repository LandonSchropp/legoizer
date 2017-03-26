# A simple wrapper for the Minimagick and ChunkyPNG libraries. This object is *mutable* because the
# underlying Minimagick library is mutable, and making this class immutable is more effort than it's
# worth.
class Image

  def initialize(minimagick_image)
    @minimagick_image = minimagick_image
    minimagick_image.format "png"
  end

  def self.read(path)
    Image.send(:new, MiniMagick::Image.open(path))
  end

  def width
    @minimagick_image.width
  end

  def height
    @minimagick_image.height
  end

  def scale(width, height)
    @minimagick_image.scale "#{ width }x#{ height }!"
  end

  # Since Minimagick doesn't yet provide a way to access the pixels of an image directly, I'm using
  # ChunkyPNG as a dirty workaround. This can likely be refatored when this issue is resolved:
  # https://github.com/minimagick/minimagick/pull/393.
  def to_a
    @minimagick_image.format "png"
    chunky_image = ChunkyPNG::Image.from_io(StringIO.new(@minimagick_image.to_blob))

    # Convert the image to a 2D array of colors
    (0...chunky_image.width).map do |x|
      (0...chunky_image.height).map do |y|

        red = (chunky_image[x, y] & 0xff000000) >> 24
        green = (chunky_image[x, y] & 0x00ff0000) >> 16
        blue = (chunky_image[x, y] & 0x0000ff00) >> 8
        alpha = (chunky_image[x, y] & 0x000000ff)

        Color.new(red: red, green: green, blue: blue, alpha: alpha)
      end
    end
  end

  # Prevent the constructor from being called outside of this class.
  private_class_method :new
end
