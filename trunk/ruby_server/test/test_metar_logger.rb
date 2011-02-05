require 'lib/metar_logger.rb'
require 'yaml'
require 'test/unit'

class TestMetarLogger < Test::Unit::TestCase

  METAR_CITY = 'EPPO'

  def test_simple
    Thread.abort_on_exception = true
    m = MetarLogger.instance

    output = nil
    assert_nothing_raised do
      output = m.fetch_and_store_city('EPPO')
    end

    assert_equal 'EPPO', output.first.city
    assert_equal 'Poland', output.first.city_hash[:country]
  end

  def test_method_start
    m = MetarLogger.instance
    out = m.start

    assert_kind_of Array, out
    assert MetarLogger.

    puts out.to_yaml
  end

end

