# http://www.leetcode.com/onlinejudge


require 'minitest/spec'
require 'minitest/autorun'


class Array
  def xsum(n, target=0)
    permutation(n).to_a.reject {|t| t.reduce(:+) != target}.map(&:sort).uniq
  end

  def threesum_closest(n)
    permutation(3).to_a.sort_by {|t| t.reduce(:+)}.keep_if {|t| t.reduce(:+) >= n}.first.reduce(:+)
  end

  # not going to create a Linked List class for this, Array will do
  def linked_list_sum
    [first.join.to_i, last.join.to_i].reduce(:+).to_s.each_char.map(&:to_i).reverse
  end

  def anagrams
    vals = reduce({}) {|acc, f| acc.merge(f => f.split("").sort.join(""))}
    reduce([]) {|res, s| res << s if vals.values.count(vals[s]) > 1 ; res}
  end

  def combination_sum(target=7, type=:several)
    unless type == :once
      each do |f|
        x = (target / f) - count(f)
        x.times {self << f}
      end
    end

    (1..size).reduce([]) do |acc, p|
      acc + permutation(p).to_a 
    end.reject {|s| s.reduce(:+) != target}.map {|t| t.sort}.uniq
  end

  # not using built in permutation cause too easy for this one...
  def combinations
    each_with_index.map {|f,i| (self - [self[i]])
      .map {|g| [f,g]} }
      .reduce([]) {|acc, h| h.each {|i| acc << i} ; acc}
      .map {|j| j.sort}.uniq
  end
end


def climbing_stairs(current=[[]], n=10, i=0)
  if i == n
    current.map {|c| c.pop while c.reduce(:+) > n}
    current.reject! {|z| z.reduce(:+) != n}
    return current.uniq.size
  end
  r = current.reduce([]) do |acc, x|
    n1, n2 = x + [1], x + [2]
    [n1, n2].each {|f| acc << f} ; acc
  end
  climbing_stairs(r, n, i+1)
end


describe "LeetCode" do 

  it "3Sum" do
    a = [-1, 0, 1, 2, -1, -4]
    a.xsum(3).must_equal([[-1, 0, 1], [-1, -1, 2]])
  end

  it "3Sum Closest" do
    a = [-1, 2, 1, -4]
    a.threesum_closest(1).must_equal(2)
  end

  it "4Sum" do
    a = [1, 0, -1, 0, -2, 2]
    a.xsum(4).must_equal([[-1,  0, 0, 1], [-2, -1, 1, 2], [-2,  0, 0, 2]])
  end

  it "Add Two Numbers" do
    l = [[2,4,3], [5,6,4]]
    l.linked_list_sum.must_equal([7,0,8])
  end

  it "Anagrams" do
    a = ["qwertz", "asdfg", "zrteqw", "poiuzg", "mnb", "lkjhfddsa", "qewrzt"]
    a.anagrams.must_equal(["qwertz", "zrteqw", "qewrzt"])
  end

  it "Climbing Stairs" do
    # hello Fibonacci !!!
    climbing_stairs([[]], 5, 0).must_equal(8)
    climbing_stairs([[]], 6, 0).must_equal(13)
    climbing_stairs([[]], 7, 0).must_equal(21)
    climbing_stairs([[]], 11, 0).must_equal(144)
    climbing_stairs([[]], 12, 0).must_equal(233)
    climbing_stairs([[]], 13, 0).must_equal(377)
  end

  it "Combination Sum" do
    [2,3,6,7].combination_sum.must_equal([[7], [2, 2, 3]])
  end

  it "Combination Sum II" do
    [10,1,2,7,6,1,5].combination_sum(8, :once).must_equal([[1, 7], [2, 6], [1, 2, 5], [1, 1, 6]])
  end

  it "Combinations" do
    [1,2,3,4].combinations.must_equal([[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]])
  end

end

