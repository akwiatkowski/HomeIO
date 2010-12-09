require './lib/metar_logger.rb'
require 'test/unit'

class TestMetarLogger < Test::Unit::TestCase

  METAR_CITY = 'EPPO'

  def test_full
    Thread.abort_on_exception = true
    m = MetarLogger.instance
    output = m.fetch_and_store_city('EPPO')

    require 'yaml'
    puts output.to_yaml
  end

end

