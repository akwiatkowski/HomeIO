require 'lib/measurement_fetcher'
require "lib/communication/io_comm/io_protocol"
require 'test/unit'

class TestMeasFetcher < Test::Unit::TestCase

  def test_start_basic
    mf = MeasurementFetcher.instance
    sleep 2
    puts mf.get_last_meas.inspect

    #res = IoProtocol.instance.fetch([0],2)
    #puts res.inspect
  end

end

