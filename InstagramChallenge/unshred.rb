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
unless File.exist?("slice_1.png")
  [0].tap do |a| 
    ((image.dimension.width/32)-1).times do 
      a << (a.last + 32)
    end
  end.each_with_index do |s,i|
    image.crop(s, 0, 32, 359).save("slice_#{i+1}.png")
  end
end


class Pixel
  include Color

  attr_accessor :rgb, :lab

  def initialize(r, g, b)
    @rgb = [r, g, b]
    @lab = xyz_to_lab
  end
end

class Slice
  include Color

  def initialize(file)
    @slice = ChunkyPNG::Image.from_file(file)
  end

# create an array of instantiated edge Pixels
  def edge_pixels(type)
    type == :end ? x = 31 : x = 0
    [].tap do |pixels|
      (0..@slice.dimension.height-1).to_a.each do |p| 
        pixels << Pixel.new(ChunkyPNG::Color.r(@slice[x,p]), ChunkyPNG::Color.g(@slice[x,p]), 
                            ChunkyPNG::Color.b(@slice[x,p]))
      end
    end
  end

  def self.distance_score(s1, s2)
    s1.edge_pixels(:end).zip(s2.edge_pixels(:start))
      .map {|arr| Color.delta_e_94(arr[0], arr[1])}
      .reduce(:+).to_i
  end
end


slices_files = (1..(image.dimension.width/32)).to_a.map {|n| "slice_#{n}.png"}

a = []

slices_files.each do |slice_file|
  scores = {slice_file => {}}
  (slices_files - [slice_file]).each do |other|
    scores[slice_file][other] = Slice.distance_score(Slice.new(slice_file), Slice.new(other))
  end 
  a << scores.map {|k,v| {k => Hash[*v.sort_by {|k,v| v}.first]}}.first
end

puts a.inspect


=begin
a = 0
s1 = Slice.new("slice_128.png")
while a <= 608
  s2 = Slice.new("slice_#{a}.png")
  puts "distance s1 avec slice_#{a}.png #{Slice.distance_score(s1,s2)}" 
  a += 32
end
=end

# plus petit score pour la dernière 7039




# 1 => 10 => 9 => 11 => 15 => 17 => 19 => 14 => 8 => 4 => 3 => 12 => 5 => 20 => 18 => 13 => 7 => 16 => 2 => 6 => 1 => 10
# la paire qui réapparait la première est les deux derniers !!!!
