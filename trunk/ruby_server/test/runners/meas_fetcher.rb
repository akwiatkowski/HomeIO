require 'lib/meas_fetcher'
require "lib/communication/io_comm/io_protocol"
require 'test/unit'

class TestMeasFetcher < Test::Unit::TestCase

  def test_start_basic
    res = IoProtocol.instance.fetch([0],2)
    puts res.inspect
  end

end

