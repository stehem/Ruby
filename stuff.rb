=begin

https://gist.github.com/2571012#comments

Question: Convert following into the latter data structure in less than 30 lines:

List:
  A, B, C
  A, C, E
  E, F, D
  D, A, J
  E, D, J

List
  A, B, 1 (frequency)
  A, C, 2
  A, D, 1
  A, E, 1
  A, J, 1
  B, C, 1
  C, E, 1
  D, E, 2
  D, F, 1
  D, J, 2
  E, F, 1
  E, J, 1

=end


# functional Ruby :-)


letters = [["A", "B", "C"], ["A", "C", "E"], ["E", "F", "D"], ["D", "A", "J"], ["E", "D", "J"]]

count_combo = lambda do |combo|
letters.reduce(0) { |memo, l| memo += 1 if [combo[0], combo[1]].all? {|k| l.include?(k)}; memo }  
end

letters.reduce([]) {|memo, x| memo << x.map {|l| (x - [l]).map {|m| l+m}}.flatten.reject {|n| n[1] < n[0]}}.flatten.uniq.sort.reduce([]) {|memo, c| memo << [c.split(""), count_combo.call(c)].flatten}


