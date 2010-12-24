require './lib/storage/storage.rb'
require 'test/unit'

class TestDbActiveRecord < Test::Unit::TestCase

  def x_test_basic
    puts Time.now.to_f
    StorageActiveRecord.instance
    puts Time.now.to_f

    CreateCities.up
    puts Time.now.to_f

    c = City.all
    puts Time.now.to_f

    CreateCities.down
    puts Time.now.to_f
  end

  def test_fill_cities
    StorageActiveRecord.instance
    CreateCities.up
    #City.create_from_config_nonmetar # XXX wywalić, przeniosłem do migracji
    #CreateCities.down
  end


end

