require 'rubygems'
require 'robustthread'

RobustThread.logger = Logger.new('log.txt')

rt = RobustThread.new(:label => "do_something with x and y") do 
  puts Time.now.to_s
  sleep 1
  1/0
end

rtb = RobustThread.new(:label => "do_something with 2x and y") do
  puts Time.now.to_s
  sleep 2
  1/0
end