# http://instagram-engineering.tumblr.com/post/12651721845/instagram-engineering-challenge-the-unshredder
# http://mjijackson.com/2008/02/rgb-to-hsl-and-rgb-to-hsv-color-model-conversion-algorithms-in-javascript
# http://www.easyrgb.com/index.php?X=MATH
# http://www.emanueleferonato.com/2009/09/08/color-difference-algorithm-part-2/
# http://en.wikipedia.org/wiki/Standard_deviation


# how this thing works, it cuts up the shredded image in 32px slices, then for each slice's edge pixels, the
# rightmost 1px column, it calculates a distance score against the leftmost 1px wie column of the other slices
# the idea being that the slice with the lowest sum of scores is the neighbour, then it finds the probable last
# slice and from then and using the scores it rebuilds the correct sequence, and subsequently the image.
# could maybe be optimized a bit, looking at only half the columns for score or caching here and there but it'll
# do, 25 secs is acceptable


require 'chunky_png'
require_relative 'compare_colors'
require_relative 'enumerable'
 


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
    @raw_scores = [].tap do |a|
      @slices_files.each do |slice_file|
        scores = {slice_file => {}}
        (@slices_files - [slice_file]).each do |other|
          scores[slice_file][other] = Slice.distance_score(Slice.new(slice_file), Slice.new(other))
        end 
        a << scores
      end
    end

    unordered = @raw_scores.map {|h| h.map {|k,v| [k,v.sort_by{|k,v| v}.first.first]}.first}

    sequence = unordered.select {|s| s[1] == last_slice} 

    sequence << unordered.detect {|seq| seq[1] == sequence.last[0] } while sequence.size <= unordered.size

    sequence.map! {|s| s.reverse}

    sequence.map! {|s| s == sequence.first ? s : [s.pop]}.flatten!

    sequence.slice!(20,sequence.size-20)

    sequence.reverse!

    @ordered_slices = sequence
  end

  def last_slice
    # this is the tricky part, how to find the last (or first, last here) slice, what i do is start by having a
    # look at the sums of all scores against other slices for each slice, the last one has to stick out somehow given 
    # that obviously there is no slice afterwards !
    # That is not enough to determine which is last with reasonable accuracy, then i look at the standard deviations
    # of the scores again for each slice, said distribution gotta be a little chaotic since the others at least have
    # one match
    # then to be sure i look at which of the now remaining slices lowest score is the highest
    # curious to see how that would work (or not !) with other shreds

    sums_of_scores = @raw_scores.map {|f| f.map {|k,v| {k => v.values.reduce(:+)}}.first}
                                .reduce({}) {|h, x| h[x.keys.first] = x.values.first;h}
                                .sort_by {|k,v| v}.last(3).map {|a| a.first}

    deviations = @raw_scores.map {|f| f.map {|k,v| {k => v.values.standard_deviation}}.first}
                            .reduce({}) {|h, x| h[x.keys.first] = x.values.first;h}
                            .sort_by {|k,v| v}.last(3).map {|a| a.first}

    possible_last = [].tap {|res| sums_of_scores.each {|f| res << f if deviations.include?(f)}}

    all_scores = @raw_scores.map {|f| f.map {|k,v| {k => v.values}}.first}
                            .reduce({}) {|h, x| h[x.keys.first] = x.values.first;h}

    {}.tap {|h| possible_last.each {|l| h[l] = all_scores[l].min}}.sort_by {|k,v| v}.last.first
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


