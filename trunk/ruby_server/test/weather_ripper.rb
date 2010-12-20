# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'weather_ripper'

class TestWeatherRipper < Test::Unit::TestCase
  def test_foo

    w = WeatherRipper.instance
    w.fetch
  end
end
