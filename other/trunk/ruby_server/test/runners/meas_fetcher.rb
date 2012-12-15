require File.join Dir.pwd, 'lib/measurements/measurement_fetcher'
require File.join Dir.pwd, "lib/communication/io_comm/io_protocol"
require 'test/unit'

class TestMeasFetcher < Test::Unit::TestCase

  def test_start_basic
    mf = MeasurementFetcher.instance
    sleep 2
    puts mf.get_last.inspect
  end

end

