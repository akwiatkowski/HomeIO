require 'lib/home_io_meas'
require 'lib/usart'

Thread.abort_on_exception = true

# test for all types of measurements
types = HomeIoMeas.instance.measurements
u = Usart.instance

puts "conn type #{u.type}"
puts "meas. count #{types.count}"

types.each do |mt|
  u.retrieve( mt )
end
