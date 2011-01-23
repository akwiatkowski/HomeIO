require './lib/metar_logger.rb'
require 'test/unit'

class TestMetarLogger < Test::Unit::TestCase

  METAR_CITY = 'EPPO'

  def test_full
    Thread.abort_on_exception = true
    m = MetarLogger.instance

    output = nil
    assert_nothing_raised do
      #output = m.fetch_and_store
      output = m.fetch_and_store_city('EPPO')
    end

    assert_equal 'EPPO', output.first.city
    assert_equal 'Poland', output.first.city_hash[:country]

    # require 'yaml'
    # puts output.to_yaml
  end

end

