require './lib/weather_ripper'
require 'test/unit'

class TestNewOnet < Test::Unit::TestCase

  def test_basic
    w = WeatherRipper.instance
    WeatherOnetPl.new.check_all
  end

end

