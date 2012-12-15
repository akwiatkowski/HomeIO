require 'rubygems'
require 'robustthread'

RobustThread.logger = Logger.new('log.txt')

@t = Time.now

puts "preA #{Time.now.to_f - @t.to_f}"

rta = RobustThread.new(:label => "do_something with x and y", :args => [21,22]) do |x,y|
  puts "** #{x}, #{y}"

  puts "start in A #{Time.now.to_f - @t.to_f}"
  sleep 1
  puts "after sleep A #{Time.now.to_f - @t.to_f}"
  sleep 1
  puts "before exception in A #{Time.now.to_f - @t.to_f}"
  1/0
end

puts "postA/preB #{Time.now.to_f - @t.to_f}"

rtb = RobustThread.new(:label => "do_something with 2x and y") do
  puts "start in B #{Time.now.to_f - @t.to_f}"
  sleep 1
  puts "after sleep B #{Time.now.to_f - @t.to_f}"
  sleep 1
  puts "before exception in B #{Time.now.to_f - @t.to_f}"
  1/0
end

puts "postB #{Time.now.to_f - @t.to_f}"
