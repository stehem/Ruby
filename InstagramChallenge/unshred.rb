# http://instagram-engineering.tumblr.com/post/12651721845/instagram-engineering-challenge-the-unshredder
# http://rogerbraun.net/selective-color-effect-with-chunkypng-or-how
# http://mjijackson.com/2008/02/rgb-to-hsl-and-rgb-to-hsv-color-model-conversion-algorithms-in-javascript
# http://www.easyrgb.com/index.php?X=MATH
# http://www.emanueleferonato.com/2009/09/08/color-difference-algorithm-part-2/
# http://www.easyrgb.com/index.php?X=CALC


require 'rubygems'
require 'chunky_png'
require_relative 'color'
 
image = ChunkyPNG::Image.from_file('TokyoPanoramaShredded.png')

# generate the 20 slices
unless File.exist?("slice_0.png")
  [0].tap do |a| 
    ((image.dimension.width/32)-1).times do 
      a << (a.last + 32)
    end
  end.each do |s|
    image.crop(s, 0, 32, 359).save("slice_#{s}.png")
  end
end

puts ChunkyPNG::Color.r(image.column(32).last)
puts ChunkyPNG::Color.g(image.column(32).last)
puts ChunkyPNG::Color.b(image.column(32).last)

class Pixel

  include Color

  attr_accessor :rgb, :lab

  def initialize(r, g, b)
    @rgb = [r, g, b]
    @lab = xyz_to_lab
  end


end
