# http://instagram-engineering.tumblr.com/post/12651721845/instagram-engineering-challenge-the-unshredder
# http://mjijackson.com/2008/02/rgb-to-hsl-and-rgb-to-hsv-color-model-conversion-algorithms-in-javascript
# http://www.easyrgb.com/index.php?X=MATH
# http://www.emanueleferonato.com/2009/09/08/color-difference-algorithm-part-2/


require 'chunky_png'
require_relative 'compare_colors'
 


class Pixel
  include CompareColors
  attr_accessor :rgb, :lab

  def initialize(r, g, b)
    @rgb = [r, g, b]
    @lab = xyz_to_lab
  end
end

class Slice
  def initialize(file)
    @slice = ChunkyPNG::Image.from_file(file)
  end

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
      .map {|arr| CompareColors.delta_e_94(arr[0], arr[1])}
      .reduce(:+).to_i
  end
end


class Unshredder

  def initialize(filename)
    raise "Image file does not exist!" unless File.exists?(filename)
    @image = ChunkyPNG::Image.from_file(filename)
    to_slices and order_slices and unshred
  end

  def to_slices
    unless File.exist?("slice_1.png")
      [0].tap do |a| 
        ((@image.dimension.width/32)-1).times do 
          a << (a.last + 32)
        end
      end.each_with_index do |s,i|
        @image.crop(s, 0, 32, 359).save("slice_#{i+1}.png")
      end
    end
    @slices_files = (1..(@image.dimension.width/32)).to_a.map {|n| "slice_#{n}.png"}
  end

  def order_slices
    a = [].tap do |a|
      @slices_files.each do |slice_file|
        scores = {slice_file => {}}
        (@slices_files - [slice_file]).each do |other|
          scores[slice_file][other] = Slice.distance_score(Slice.new(slice_file), Slice.new(other))
        end 
        a << scores
      end
    end

    a.map! {|h| h.map {|k,v| [k,v.sort_by{|k,v| v}.first.first]}.first}

    sequence = [a.first]

    sequence << a.detect {|seq| seq[0] == sequence.last[1] } while sequence.size <= a.size

    2.times {sequence.shift}

    sequence.map! {|s| s == sequence.first ? s : [s.pop]}.flatten!

    @ordered_slices = sequence
  end

  def unshred
    result = ChunkyPNG::Image.new(@image.dimension.width, @image.dimension.height, ChunkyPNG::Color::TRANSPARENT)

    offset = 0
    @ordered_slices.each do |s|
      slice = ChunkyPNG::Image.from_file(s)
      result = result.replace!(slice, offset_x = offset, offset_y = 0)
      offset += 32
    end

    result.save('Unshredded.png')

    Dir.foreach(".") {|x| File.delete(x) if x =~ /slice/ }
  end

end



Unshredder.new('TokyoPanoramaShredded.png')


