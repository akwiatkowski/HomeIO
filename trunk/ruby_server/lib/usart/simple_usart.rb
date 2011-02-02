require 'rubygems'
require 'serialport'

class SimpleUsart
  def initialize
  end

  def test
    sp = SerialPort.new "/dev/ttyS0"
    sp.baud = 38400
    sp.parity = SerialPort::EVEN
    #sp.data_bits = 8
    #sp.stop_bits = 1

    sp.write 's'
    a = sp.read
    puts a

  end
end


s = SimpleUsart.new
s.test