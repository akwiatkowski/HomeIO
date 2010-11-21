require 'lib/geolocation'
require 'test/unit'

class TestConfigLoader < Test::Unit::TestCase

  def test_basic
    g = Geolocation.new

    puts g.lat
    puts g.lon

    puts g.distance( 0,0 )

  end

  # checking aprox. distance
  def test_distance
    # distance from 52.627506,18.168679 to 0,0 in km = 6090.86
    # http://www.geodatasource.com/distancecalculator.aspx
    distance_should_be = 6090.86
    distance_calculated = Geolocation.distance( 0, 0 )

    assert_in_delta distance_should_be, distance_calculated, 30.0, 'wrong calcualted distance'
    assert_in_delta 1.0, distance_should_be / distance_calculated, 0.02, 'wrong relative calcualted distance'

    puts
  end

end

