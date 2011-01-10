require './lib/weather_ripper.rb'
require 'test/unit'

class TestWeatherRipper < Test::Unit::TestCase

  def test_onet_pl
    # onet.pl use latin2 - yuck!
    f = File.open("./test/fixtures/weather_ripper/0,846,38,,,inowroclaw,miasto.html", "r:ISO-8859-2")
    str = f.read
    f.close
    #puts str.encoding

    w = WeatherOnetPl.new
    data = w.process( str )

    # times
    assert_equal 19, data[0][:time_from].hour
    assert_equal 1, data[0][:time_to].hour

    assert_equal 1, data[1][:time_from].hour
    assert_equal 7, data[1][:time_to].hour

    # weather data
    assert_equal -1, data[0][:temperature]
    assert_equal -2, data[1][:temperature]

    #puts str
    puts data.inspect
  end

end

