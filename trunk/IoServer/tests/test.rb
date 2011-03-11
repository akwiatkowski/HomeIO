#!/usr/bin/ruby

# Simple test for IoServer

require 'socket'

hostname = '192.168.0.104'
hostname = 'localhost'
hostname = '5.62.110.45'
port = 2002

# 't' test
t = Time.now
10.times do
  s = TCPSocket.open(hostname, port)

  # <count of command bytes> <count of response bytes> <command bytes>
  str = 1.chr + 2.chr + 't'
  s.puts str
  data = s.gets
  int_data = (data[0] * 256 + data[1])
  puts int_data if int_data != 12345
  s.close               # Close the socket when done
end
puts "'t' test"
puts Time.now.to_f - t.to_f

# 's' test
t = Time.now
10.times do
  s = TCPSocket.open(hostname, port)

  # <count of command bytes> <count of response bytes> <command bytes>
  str = 1.chr + 1.chr + 's'
  s.puts str
  data = s.gets
  int_data = data[0]
  puts int_data if int_data != 0
  s.close               # Close the socket when done
end
puts "'0' test"
puts Time.now.to_f - t.to_f

