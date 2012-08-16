# cool exercise, basically means finding all numbers whose sum is 0
require 'minitest/spec'
require 'minitest/autorun'


class Hash

  def zero_sum
    start, max, res, done = 2, self.size, nil, nil
  
    while start <= max
      self.to_a.combination(start).to_a.each do |comb|
        res = comb and done = true and break if comb.map(&:last).reduce(:+) == 0
      end
      break if done
      start+=1
    end

    res.map(&:first) if res
  end

end



describe "Zero Sum" do
  it "Works" do
    data = {maria: -15, roberto: 45, hugo: 20, hidalgo: -5, ricardo: 25, margarita: 5}
    result = data.zero_sum
    result.must_equal([:hidalgo, :margarita])
    result.map {|player| data[player]}.reduce(:+).must_equal(0)
    data = {maria: -15, roberto: 45, hugo: 20, hidalgo: -5, ricardo: 25, margarita: -10}
    result = data.zero_sum
    result.must_equal([:maria, :hugo, :hidalgo])
    result.map {|player| data[player]}.reduce(:+).must_equal(0)
    data = {maria: -10, roberto: 35, hugo: -10, hidalgo: -5, ricardo: 25, margarita: -10}
    result = data.zero_sum
    result.must_equal([:maria, :hugo, :hidalgo, :ricardo])
    result.map {|player| data[player]}.reduce(:+).must_equal(0)
    data = {maria: -10, roberto: 35, hugo: -1, hidalgo: -5, ricardo: -2, margarita: -10}
    result = data.zero_sum
    result.must_equal(nil)
    data = {maria: -10, roberto: 45, hugo: -10, hidalgo: -5, ricardo: -10, margarita: -10}
    result = data.zero_sum
    result.must_equal([:maria, :roberto, :hugo, :hidalgo, :ricardo, :margarita])
    result.map {|player| data[player]}.reduce(:+).must_equal(0)
  end
end



