require File.join Dir.pwd, 'lib/home_io_meas'
require File.join Dir.pwd, 'lib/usart'

Thread.abort_on_exception = true

# test for all types of measurements
types = HomeIoMeas.instance.measurements
u = Usart.instance

puts "conn type #{u.type}"
puts "meas. count #{types.count}"

types.each do |mt|
  u.retrieve( mt )
end
