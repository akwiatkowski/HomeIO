require 'lib/geolocation'
require 'test/unit'

class TestConfigLoader < Test::Unit::TestCase

  def test_basic
    g = Geolocation.new

    puts g.lat
    puts g.lon

    puts g.distance( 0,0 )

  end

end

