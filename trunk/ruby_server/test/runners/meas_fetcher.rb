require 'lib/measurement_fetcher'
require "lib/communication/io_comm/io_protocol"
require 'test/unit'

class TestMeasFetcher < Test::Unit::TestCase

  def test_start_basic
    mf = MeasurementFetcher.instance
    sleep 2
    puts mf.get_last.inspect
  end

end

