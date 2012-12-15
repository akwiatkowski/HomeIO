require './lib/storage/storage.rb'
require 'test/unit'

class TestDbActiveRecord < Test::Unit::TestCase

  def test_basic
    StorageActiveRecord.instance
    cities = City.all
    assert cities.size > 0

    # test if tables are availabe
    assert_nothing_raised do
      City.last

      wma = WeatherMetarArchive.last
      wma.city

      assert_equal City.find( wma.city_id), wma.city

      
      wa = WeatherArchive.last
      wa.city

      assert_equal City.find( wa.city_id), wa.city

      wa.weather_provider
    end
  end

  def test_create_simple_city
    StorageActiveRecord.instance

    c = City.new
    assert_equal false, c.valid?
  end


end

