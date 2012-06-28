# http://www.leetcode.com/onlinejudge


require 'minitest/spec'
require 'minitest/autorun'
require 'benchmark'
require 'matrix'


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
    each_with_index.map do |f,i| 
      a = self.dup
      a.delete_at(i)
      a.map {|g| [f,g]} 
    end
      .reduce([]) {|acc, h| h.each {|i| acc << i} ; acc}
      .map(&:sort).uniq
  end

  def missing_positive
    a = sort.drop_while {|n| n <  0}
    a.reduce(a[0]) do |acc, n| 
      break acc if n != acc
      acc += 1
    end
  end

  def insert_interval(b)
    a = map {|f| (f.first..f.last).to_a}
    a << (b.first..b.last).to_a
    a.sort_by!(&:first)
    t = [].tap do |arr| 
      a.each_with_index do |seq, i|
        c = a.dup
        c.delete_at(i)
        c.each {|f| arr << seq if (seq & f).any?}
      end
    end
    q = t.uniq.flatten
    m = [q.min, q.max]
    t.each {|f| a.delete(f)}
    a << m
    a.sort_by(&:first).map{|f| [f.first,f.last]}
  end

  def jump_game(type=:std, res=[[0]], goal=self.size-1)
    if res.any? {|f| f.last == goal}
      return res.select {|f| f.last == goal}.first.size-1 if type == :min
      return true
    end
    return false if res.empty?
    next_ = lambda {|i| (i+1..i+self[i]).to_a}
    next_a = lambda {|arr| next_[arr.last].map {|f| arr + [f]}}
    next_res = res.reduce([]) do |acc,r|
      next_a[r].each {|s| acc << s} ; acc
    end
    jump_game(type, next_res, goal)
  end

  def longest_prefix
    i = 0
    while i < size
      self[i] = nil unless (self-[self[i]]).any? {|f| f and f.split("").first == self[i].split("").first}
      i+=1
    end
    delete_if(&:nil?)
    res = []
    each do |x|
      aa = dup
      b = x.split("").each_with_index.reduce(-1) do |acc, (f,k)|
        aa.delete(x) and aa.delete_if {|y| y.split("").first != f} if k == 0
        aa.any? {|g| g.split("")[k] == f} ? acc+=1 : (break acc)
      end
      res << x[0..b] if b
    end
    res.uniq.sort_by(&:size).last
  end

  def maximum_subarray
    res, i = [[0]], 0
    while i < size - 1
      j = i + 1
      while j < size
        res << self[i..j] and res.shift if self[i..j].reduce(:+) > res.last.reduce(:+)  
        j+=1 
      end
      i+=1
    end
    res.first
  end
end


def climbing_stairs(n=10, current=[[]], i=0)
  if i == n
    current.map {|c| c.pop while c.reduce(:+) > n}
    current.reject! {|z| z.reduce(:+) != n}
    return current.uniq.size
  end
  r = current.reduce([]) do |acc, x|
    n1, n2 = x + [1], x + [2]
    [n1, n2].each {|f| acc << f} ; acc
  end
  climbing_stairs(n, r, i+1)
end


def container_water(coords)
  coords.permutation(2).to_a
    .map(&:sort).uniq
    .map {|cont| {cont => {
      :height => cont.sort_by(&:last).first.last, 
      :width => cont.sort_by(&:first).last.first - cont.sort_by(&:first).first.first
    }}}
    .map {|cont| cont.map {|k,v| {k => v[:height] * v[:width]}}.first}
    .sort_by(&:values)
    .reverse.first
end


def countsay(n, res="1", c=1)
  return res if c == n
  a = res.split("")
  i, count, step = 0, 1, ""
  while i < a.size
    i+=1 and count+=1 while a[i] == a[i+1] if a[i] == a[i+1]
    step << "#{count}#{a[i]}" and i+=1 and count = 1
  end
  countsay(n, step, c+1)
end


# divide two integers without using / * and mod
def divide(a,b)
  i = 0
  a -= b and i += 1 while a >= b
  x, y = 0, 0
  while a - y >= 0.01
    x += 0.01 
    y = x 
    b.times {y += x} and y -= x
  end
  i + x
end


def parentheses(n)
  a = ""
  n.times {a << "()"}
  a.split("")
    .permutation(n*2).to_a
    .map {|f| f.join("")}.uniq
    .select {|f| not f =~ /\($|^\)/}
    .delete_if {|f| f.gsub(/\(\)/,"") =~ /\)\(/ }
end


# patching to allow mutability
class Matrix 
  def []=(i, j, x) 
    @rows[i][j] = x 
  end 

  def maximal_rectangle
    # it is decently optimized for a bruteforceish solution but i'm sure there is a 
    # more elegant way to solve this, anyway it will do a 50x50 matrix in about 5 secs
    m,res = self, []
    m.each_with_index do |e, r, c|
      next if [e, m[r+1,c], m[r,c+1], m[r+1,c+1]].any? {|f| f.nil? or f == 0}
      res << [r,c]
    end

    only_ones = lambda do |r1,c1,r2,c2|
      not [].tap {|a| (c1..c2).to_a.each{|c| (r1..r2).to_a.each {|r| a << m[r,c]}}}.include?(0)
    end

    nb_of_ones = lambda {|r1,c1,r2,c2| (c2+1-c1)*(r2+1-r1)}

    corner = [res.sort_by(&:first).last.first+1,res.sort_by(&:last).last.last+1] 

    result = []
    res.each do |r|
      xx,yy = corner.first,corner.last

      while xx > r.first and yy > r.last
        x,y = xx,yy
        while x > r.first
          result << [r, [x,y]] if m[x,y] != 0 and only_ones[r.first,r.last,x,y] 
          x-=1
        end
        while y > r.last
          x = xx
          result << [r, [x,y]] if m[x,y] != 0 and only_ones[r.first,r.last,x,y] 
          y-=1
        end
        xx-=1 and yy-=1
      end
    end

    result = result.uniq
    #lazy
    max = result.map {|f| nb_of_ones[f.first.first,f.first.last,f.last.first,f.last.last]}.max
    result.delete_if {|f| nb_of_ones[f.first.first,f.first.last,f.last.first,f.last.last] < max}
  end

  def maximum_path
    children = lambda do |path| 
      d, r = [path.last.first+1, path.last.last], [path.last.first, path.last.last+1]
      down = d if eval "self#{d}" 
      right = r if eval "self#{r}"
      [down, right]
    end
    paths = [[[0,0]]]
    while paths.first.size < (column(0).size + row(0).size - 1)
      paths = [].tap {|res| paths.each {|p| children[p].each {|c| res << p + [c] unless (p + [c]).include?(nil)}}}
    end
    paths.map {|path| [path.map {|p| eval "self#{p}"}.reduce(:+), path]}.sort_by(&:first).last.last
  end
end

class String
  # implementation of the Levenshtein algorithm described here http://www.merriampark.com/ld.htm
  def levenshtein(t)
    s, t = self.split(""), t.split("")
    i, j = s.size, t.size
    m = Matrix.build(j+1,i+1) {0}
    (0..i).to_a.each {|f| m[0,f] = f}
    (0..j).to_a.each {|f| m[f,0] = f}
    (1..i).to_a.each do |col|
      (1..j).to_a.each do |f|
        cost = s[col-1] == t[f-1] ? 0 : 1
        above, left, diag = m[f-1,col] + 1, m[f,col-1] + 1, m[f-1,col-1] + cost
        m[f,col] = [above,left,diag].min
      end
    end
    m[j,i]
  end

  def length_of_last_word
    split(/\s+/).last.size
  end

  # this is the recursive version, it works until 3**5 and then it throws stack too deep errors
  # it seems tail call optimization exists in 1.9 but isn't on by default :-(
  # recursion is sort of flaky in Ruby, i have been spoiled by Clojure, need to get back to it
  # anyway the iterative version is cleaner
=begin
  def phone_combinations(res=nil)
    return res.first if res and res.first.size == 3**self.size
    letters = {"0" => "", "1" => "", "2" => "abc", "3" => "def", 
      "4" => "ghi", "5" => "jkl", "6" => "mno", "7" => "pqrs", 
      "8" => "tuv", "9" => "wxyz"}
    arr = res ? res : split("").map{|f| letters[f]}.map {|f| f.split("")}
    combine = lambda {|s1,s2| res = [] ; s1.each {|f| s2.map {|g| res << [f,g]}} ; res.map(&:join)}
    c = arr[1] && combine.call(arr[0],arr[1])
    arr.insert(0, c) and arr.delete_at(1) and arr.delete_at(1) if c
    phone_combinations(arr)
  end
=end

  def phone_combinations
    letters = {"0" => "", "1" => "", "2" => "abc", "3" => "def", 
      "4" => "ghi", "5" => "jkl", "6" => "mno", "7" => "pqrs", 
      "8" => "tuv", "9" => "wxyz"}
    a = split("").map{|f| letters[f]}.map {|f| f.split("")}.delete_if(&:empty?)
    combine = lambda {|s1,s2| s1.reduce([]) {|r,f| s2.map {|g| r << [f,g]} ;r}.map(&:join)}
    a[0] = combine[a[0], a[1]] and a.delete_at(1) while a.size != 1
    a.first
  end

  def palindromic_substring
    res, i = [], 0
    while i < size - 1
      j = i + 1
      while include?(self[i..j].reverse)
        res << self[i..j] if self[i..j].size >= 2
        j+=1 
      end
      i+=1
    end
    res.sort_by(&:size).last
  end

  def substring_without_repeat
    res, i = [], 0
    while i < size - 1
      j = i
      while self[i..j].split("").uniq == self[i..j].split("") and j < size
        res << self[i..j] if self[i..j] != ""
        j+=1 
      end
      i+=1
    end
    res.delete_if {|f| f.size < res.sort_by(&:size).last.size}.uniq
  end

  def longest_valid_parentheses
    a, i, res = split(""), 0, []
    while i < a.size
      j = i + 1
      while j < a.size
        res << a[i..j] and j+=1
      end
      i+=1
    end
    res.delete_if {|f| f.size.odd?}
      .delete_if {|f| f.count("(") != f.count(")")}
      .delete_if {|f| f.first == ")" or f.last == "("}
      .map! {|f| f.each_slice(f.size/2).to_a}
      .delete_if {|f| f.first.count(")") > f.first.count("(") or f.last.count("(") > f.last.count(")")}
      .map! {|f| f.join("")}
      .sort_by(&:size).last
  end

  def window_substring(target)
    # complexity seems to be O(n) : 1000 chars => 10ms, 5000 chars => 60ms, 25000 chars => 500ms
    str, tar, subs, i = self.split(""), target.split(""), [], 0
    find_next_index = lambda do |arr, start=nil| 
      arr_ = arr.dup 
      arr_[0] = nil unless start 
      arr_.find_index {|l| tar.include?(l)}
    end
    last_index = lambda {|arr| fletter = arr[0] ; (tar-[fletter]).map{|l| arr.index(l)}.reject(&:nil?).sort.last}
    while subs.empty? ? true : tar.all? {|f| subs.last.include?(f)}
      next_index = i == 0 ? find_next_index[str, :start] : find_next_index[str]
      str = str[next_index..-1]
      sub = str[0..last_index[str]]
      subs << sub
      i+=1
    end
    subs.pop and subs.sort_by(&:size).first.join("")
  end
end


class Integer
  def to_roman
    r = {
      :th => {1 => "M"}, 
      :hu => {0 => "", 1 => "C", 2 => "CC", 3 => "CCC", 4 => "CD", 
        5 => "D", 6 => "DC", 7 => "DCC", 8 => "CCM", 9 => "CM",}, 
      :te => {0 => "", 1 => "X", 2 => "XX", 3 => "XXX", 4 => "XL", 
        5 => "L", 6 => "LX", 7 => "LXX", 8 => "XXC", 9 => "XC"}, 
      :de => {0 => "", 1 => "I", 2 => "II", 3 => "III", 4 => "IV", 
        5 => "V", 6 => "VI", 7 => "VII", 8 => "VIII", 9 => "IX"}}
    a, res = to_s.split(""), ""
    case self
    when 1000..3999
      a[0].to_i.times {res << r[:th][1]}
      res << r[:hu][a[1].to_i]
      res << r[:te][a[2].to_i]
      res << r[:de][a[3].to_i]
    when 100..999
      res << r[:hu][a[0].to_i]
      res << r[:te][a[1].to_i]
      res << r[:de][a[2].to_i]
    when 10..99
      res << r[:te][a[0].to_i]
      res << r[:de][a[1].to_i]
    when 0..9
      res << r[:de][a[0].to_i]
    end
    res
  end
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
    climbing_stairs(5).must_equal(8)
    climbing_stairs(6).must_equal(13)
    climbing_stairs(7).must_equal(21)
    climbing_stairs(11).must_equal(144)
    climbing_stairs(12).must_equal(233)
    climbing_stairs(13).must_equal(377)
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

  it "Container With Most Water" do
    container_water([[65, 24], [53, 15], [89, 33], [68, 22], [60, 80]]).must_equal({[[60, 80], [89, 33]]=>957})
  end

  it "Count And Say" do 
    countsay(2).must_equal("11")
    countsay(6).must_equal("312211")
    countsay(7).must_equal("13112221")
    countsay(8).must_equal("1113213211")
    countsay(9).must_equal("31131211131221")
  end

  it "Divide Two Integers" do
    a = 11/3.to_f
    assert_in_delta(a, divide(11,3), 0.01)
    a = 47/12.to_f
    assert_in_delta(a, divide(47,12), 0.01)
    a = 234/67.to_f
    assert_in_delta(a, divide(234,67), 0.01)
    a = 1234/92.to_f
    assert_in_delta(a, divide(1234,92), 0.01)
  end  

  it "Edit Distance" do
    "kitten".levenshtein("sitting").must_equal(3)
    "saturday".levenshtein("sunday").must_equal(3)
    "meilenstein".levenshtein("levenshtein").must_equal(4)
    "ruby".levenshtein("python").must_equal(6)
    "alghorithn".levenshtein("algorithm").must_equal(2)
  end

  it "First Missing Positive" do
    [1,2,0].missing_positive.must_equal(3)
    [3,4,-1,1].missing_positive.must_equal(2)
    [-23,-99,100,4,5,6,7,12,1000].missing_positive.must_equal(8)
  end

  it "Insert Interval" do
    [[1,3],[6,9]].insert_interval([2,5]).must_equal([[1,5],[6,9]])
    [[1,2],[3,5],[6,7],[8,10],[12,16]].insert_interval([4,9]).must_equal([[1,2],[3,10],[12,16]])
  end

  it "Integer To Roman" do
    64.to_roman.must_equal("LXIV")
    226.to_roman.must_equal("CCXXVI")
    900.to_roman.must_equal("CM")
    998.to_roman.must_equal("CMXCVIII")
    1712.to_roman.must_equal("MDCCXII")
  end

  it "Jump Game" do
    [2,3,1,1,4].jump_game.must_equal(true)
    [3,2,1,0,4].jump_game.must_equal(false)
    [2,3,1,2,4,1,2,0,0,0,0].jump_game.must_equal(false)
    [1,1,1,1,1].jump_game.must_equal(true)
    [4,1,1,1,2,2,0,0].jump_game.must_equal(true)
    [2,1,0,1,1].jump_game.must_equal(false)
  end

  it "Jump Game II" do
    [2,3,1,1,4].jump_game(:min).must_equal(2)
    [3,2,1,0,4].jump_game(:min).must_equal(false)
    [1,1,1,1,1].jump_game(:min).must_equal(4)
    [4,1,2,1,3,2,0,0].jump_game(:min).must_equal(2)
    [4,1,1,1,4,1,1,1,0].jump_game(:min).must_equal(2)
  end

  it "Length Of Last Word" do
    "Hello World".length_of_last_word.must_equal(5)
    "This one was way too easy".length_of_last_word.must_equal(4)
  end

  it "Letter Combinations Of A Phone Number" do
    "23".phone_combinations.must_equal(["ad", "ae", "af", "bd", "be", "bf", "cd", "ce", "cf"])
    "234".phone_combinations.must_equal(["adg", "adh", "adi", "aeg", "aeh", "aei", "afg", "afh", 
      "afi", "bdg", "bdh", "bdi", "beg", "beh", "bei", "bfg", "bfh", "bfi", "cdg", "cdh", "cdi", 
      "ceg", "ceh", "cei", "cfg", "cfh", "cfi"])
    "2345".phone_combinations.size.must_equal(3**4)
    "23456".phone_combinations.size.must_equal(3**5)
    "234567".phone_combinations.size.must_equal((3**5)*4)
    "2345678".phone_combinations.size.must_equal((3**6)*4)
    "23456789".phone_combinations.size.must_equal((3**6)*4*4)
    "012345".phone_combinations.size.must_equal("2345".phone_combinations.size)
    time = Benchmark.realtime {"23456789".phone_combinations}
    p "Time elapsed for generating 11664 phone combinations: #{time*1000} milliseconds"
  end

  it "Longest Common Prefix" do
    a = ['papillon', 'papyrus', "calife", 'voiture', "abd", 'qwertz', 'papoteur', 
      "voilure", "yyyy", "calipso", "abc"]
    a.longest_prefix.must_equal("cali")
  end

  it "Longest Palindromic Substring" do
    "qwertzlneveroddorevenasdfgyxcvbn".palindromic_substring.must_equal("neveroddoreven")
    "qweasdyxclrisetovotesirpoiuzlkjhgmnb".palindromic_substring.must_equal("risetovotesir")
    "qwertzuamanaplanacanalpanamayxcvbnmasdfghjkl".palindromic_substring.must_equal("amanaplanacanalpanama")
    "qwertzuasdfgyxcvbn".palindromic_substring.must_equal(nil)
  end

  it "Longest Substring Without Repeating Characters" do
    "abcabcbb".substring_without_repeat.must_equal(["abc", "bca", "cab"])
    "bbbbb".substring_without_repeat.must_equal(["b"])
    "qwertzaaddhjkjjk".substring_without_repeat.must_equal(["qwertza"])
    "qqqqqqqqqqqqqqa".substring_without_repeat.must_equal(["qa"])
  end

  it "Longest Valid Parentheses" do
    "))()))((()".longest_valid_parentheses.must_equal("()")
    "))()()".longest_valid_parentheses.must_equal("()()")
    "(()".longest_valid_parentheses.must_equal("()")
    ")()())".longest_valid_parentheses.must_equal("()()")
    ")((())))".longest_valid_parentheses.must_equal("((()))")
    ")((()))())".longest_valid_parentheses.must_equal("((()))()")
  end


  it "Maximal Rectangle" do
    m = Matrix[
      [0,  1,  1,  0,  1],
      [1,  1,  0,  1,  0],
      [0,  1,  1,  1,  1],
      [1,  1,  1,  1,  0],
      [1,  1,  1,  1,  0],
      [0,  0,  0,  0,  0]
    ]
    m.maximal_rectangle.must_equal([[[2,1], [4,3]]])
    m = Matrix[
      [0,  1,  1,  0,  1],
      [1,  1,  0,  1,  0],
      [0,  1,  1,  1,  1],
      [1,  1,  1,  1,  0],
      [0,  1,  1,  0,  0],
      [0,  0,  0,  0,  0]
    ]
    m.maximal_rectangle.must_equal([[[2,1], [3,3]], [[2,1], [4,2]]])
    m = Matrix[
      [0,  1,  1,  0,  1],
      [1,  1,  0,  1,  0],
      [0,  1,  1,  1,  1],
      [1,  1,  1,  1,  1],
      [0,  1,  0,  1,  0],
      [0,  0,  0,  0,  0]
    ]
    m.maximal_rectangle.must_equal([[[2,1], [3,4]]])
    m = Matrix[
      [1,  1,  1,  0,  0],
      [1,  1,  1,  0,  0],
      [0,  0,  0,  0,  0],
      [0,  0,  0,  0,  0],
      [0,  0,  1,  1,  1],
      [0,  0,  1,  1,  1]
    ]
    m.maximal_rectangle.must_equal([[[0,0], [1,2]], [[4,2], [5,4]]])
    time = Benchmark.realtime {Matrix.build(20,20) {rand 2}.maximal_rectangle}
    p "Time elapsed for finding the maximal rectangle in a 20x20 matrix: #{time*1000} milliseconds"
  end

  it "Maximum Subarray" do
    [-2,1,-3,4,-1,2,1,-5,4].maximum_subarray.must_equal([4, -1, 2, 1])
    [0,9,-10,5,5,5,-7,1,2,4].maximum_subarray.must_equal([5,5,5])
    [0,9,-8,5,5,5,-7,1,2,4].maximum_subarray.must_equal([0,9,-8,5,5,5])
    [-1,-2,3,3,3,3,-2].maximum_subarray.must_equal([3,3,3,3])
    time = Benchmark.realtime {[].tap {|f| 100.times {f << rand(11)}}.maximum_subarray}
    p "Time elapsed for analysing a 100 elements array: #{time*1000} milliseconds"
  end

  it "Maximum Path Sum" do
    m = Matrix[
      [1,  3,  1,  0,  0],
      [9,  8,  1,  0,  0],
      [5,  9,  8,  0,  0],
      [0,  1,  8,  0,  0],
      [0,  0,  9,  9,  1],
      [0,  0,  1,  8,  1]
    ]
    m.maximum_path.must_equal([[0,0], [1,0], [1,1], [2,1], [2,2], [3,2], [4,2], [4,3], [5,3], [5,4]])
    m = Matrix[
      [1,  1,  1,  1,  1],
      [0,  0,  0,  0,  1],
      [0,  0,  0,  0,  1],
      [0,  0,  0,  0,  1],
      [0,  0,  0,  0,  1],
      [0,  0,  0,  0,  1]
    ]
    m.maximum_path.must_equal([[0,0], [0,1], [0,2], [0,3], [0,4], [1,4], [2,4], [3,4], [4,4], [5,4]])
    # only 6x6 to keep things fast because the nb of paths quickly gets enormous
    time = Benchmark.realtime {Matrix.build(6,6) {rand 11}.maximum_path}
    p "Time elapsed for finding the minimum sum path of a 6x6 matrix: #{time*1000} milliseconds"
  end

  it "Minimum Window Substring" do
    "ADOBECODEBANC".window_substring("ABC").must_equal("BANC")
    "QWERASDFBSFSDCQWEERWABCOITUAKJLB".window_substring("ABC").must_equal("ABC")
    "QWERASDFBSFSDCQWEERWCBQAOITUAKJLB".window_substring("ABC").must_equal("CBQA")
    "WWWXAAYBBZPOUJXCYCZQWEQQ".window_substring("XYZ").must_equal("XCYCZ")
    "WWWXAAYBBZPOUJZCYACXQWEQQ".window_substring("XYZ").must_equal("ZCYACX")
    "AABC".window_substring("ABC").must_equal("ABC")
    "AABBC".window_substring("ABC").must_equal("ABBC")
    time = Benchmark.realtime {str = ""; 5000.times {str << (("A".."Z").to_a)[rand(26)]}; str.window_substring("YABC")}
    p "Time elapsed for finding the minimum window substring of a 5000 chars string: #{time*1000} milliseconds"
  end

end







