require './lib/extractors/extractor_active_record.rb'
require './lib/storage/storage.rb'

require 'test/unit'

class TestExtractor < Test::Unit::TestCase

  def test_basic
    e = ExtractorActiveRecord.instance

    #searching_city('poz')
    #puts e.search_city( 'EPPO' ).inspect

    # city search
    # puts e.search_city( 'EPPO' ).inspect
    assert_equal 'Poznań', e.search_city( 'EPPO' ).name
    assert_equal 'EPPO', e.search_city( 'Poznań' ).metar
    assert_equal 'EPPO', e.search_city( 'poz' ).metar

    metar_code = 'EPPO'
    last_metar = e.get_last_metar( metar_code )
    wma = City.find_by_metar( metar_code ).weather_metar_archives.find(:last)
    # puts wma.inspect, last_metar.inspect

    assert_equal wma.time_from, last_metar[:time]
    assert_in_delta wma.wind, last_metar[:wind], 0.1

    per = e.city_periodical_stats_for_city_name('poz', Time.now - 24*3600, Time.now, nil)
    #puts e.search_city( 'Amud' ).inspect

    #city = 'Mog'
    #c = City.find(:all, :conditions => ["name like ?", "%#{city}%"])
    #puts c.inspect
  end

  private

  def searching_city( city )
    puts City.find_by_id( city ).inspect
    puts City.find_by_name( city ).inspect
    puts City.find_by_metar( city ).inspect
    puts City.find(:first, :conditions => ["lower(name) like lower(?)", "%#{city}%"]).inspect
  end

end

