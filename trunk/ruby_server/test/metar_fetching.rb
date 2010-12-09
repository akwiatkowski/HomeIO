require './lib/metar_logger.rb'
require 'test/unit'

class TestMetarFetching < Test::Unit::TestCase

  METAR_CITY = 'EPPO'

  def test_full
    require './lib/metar_tools.rb'
    require './lib/metar_logger.rb'

    Thread.abort_on_exception = true
    config = MetarTools.load_config
    # without starting
    config[:start] = false
    m = MetarLogger.new( config )
    output = m.fetch_and_store_city('EPPO')

    #require 'yaml'
    #puts output.to_yaml
  end

end

