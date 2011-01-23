require './lib/weather_ripper.rb'
require 'test/unit'

class TestWeatherRipper < Test::Unit::TestCase

  def test_onet_pl
    # onet.pl use latin2 - yuck!
    f = File.open("./test/fixtures/weather_ripper/WeatherOnetPl/0,846,38,,,inowroclaw,miasto.html", "r:ISO-8859-2")
    str = f.read
    f.close
    #puts str.encoding

    w = WeatherOnetPl.new
    data = w.process( str )

    # TODO waiting for onet fix they www
    puts data.inspect

    assert_equal (3.0 / 3.6), data.select{|d| d[:time_from].day == 10 and d[:time_from].month == 1 and d[:time_from].hour == 0 and d[:time_to].hour == 0 }.first[:wind]

    # times
    #    assert_equal 19, data[0][:time_from].hour
    #    assert_equal 1, data[0][:time_to].hour
    #
    #    assert_equal 1, data[1][:time_from].hour
    #    assert_equal 7, data[1][:time_to].hour
    #
    #    # weather data
    #    assert_equal -1, data[0][:temperature]
    #    assert_equal -2, data[1][:temperature]

    #puts str
    # puts data.inspect
  end

  def test_wp_pl
    f = File.open("./test/fixtures/weather_ripper/WeatherWpPl/miasto,bydgoszcz,mid,1201023,mi.html", "r:ISO-8859-2")
    str = f.read
    f.close
    #puts str.encoding

    w = WeatherWpPl.new
    data = w.process( str )

    # random test
    assert_equal -2, data.select{|d| d[:time_from].hour == 0 and d[:time_from].day == 24}.first[:temperature]
    assert_equal (7.2 / 3.6), data.select{|d| d[:time_from].hour == 12 and d[:time_from].day == 24}.first[:wind]
    assert_equal (7.2 / 3.6), data.select{|d| d[:time_from].hour == 12 and d[:time_from].day == 27}.first[:wind]
    assert_equal -1, data.select{|d| d[:time_from].hour == 6 and d[:time_from].day == 26}.first[:temperature]
    assert_equal 1, data.select{|d| d[:time_from].hour == 18 and d[:time_from].day == 25}.first[:temperature]
    assert_equal (10.8 / 3.6), data.select{|d| d[:time_from].hour == 0 and d[:time_from].day == 24}.first[:wind]

    assert_equal 16, data.size

    #puts str
    #puts data.inspect
  end

end

