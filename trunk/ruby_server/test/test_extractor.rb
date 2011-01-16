require './lib/storage/extractors/extractor_active_record.rb'
require 'test/unit'

class TestExtractor < Test::Unit::TestCase

  def test_basic
    e = ExtractorActiveRecord.instance

    puts e.search_city( 'EPPO' ).inspect
    # assert_equal 'Poznań', e.search_city( 'EPPO' ).name
    # assert_equal 'EPPO', e.search_city( 'Poznań' ).metar

    #puts e.search_city( 'Amud' ).inspect

    city = 'Mog'
    c = City.find(:all, :conditions => ["name like ?", "%#{city}%"])
    puts c.inspect
  end

end

