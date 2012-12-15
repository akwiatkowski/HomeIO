# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require './lib/weather_ripper'
require './lib/weather_ripper/weather_onet_pl.rb'
require './lib/weather_ripper/weather_onet_pl_b.rb'
require './lib/weather_ripper/weather_onet_pl_c.rb'

class TestWeatherOnet < Test::Unit::TestCase
  def test_foo

    WeatherRipper.instance
    w = WeatherOnetPlC.new
    wa = WeatherOnetPl.new

    body = w.fetch( w.defs.first )
    processed = w.process( body )
    puts processed.inspect

    processed = wa.process( body )
    puts processed.inspect

  end
end
