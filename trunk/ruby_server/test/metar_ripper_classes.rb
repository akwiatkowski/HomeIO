require './lib/metar_ripper/metar_ripper.rb'
require 'test/unit'

class TestMetarRipperClasses < Test::Unit::TestCase

  METAR_CITY = 'EPPO'

  def test_basic

    MetarRipper.instance.klasses.each do |k|
      ma = k.new
      metar = ma.fetch( METAR_CITY )

      # sometime site show nothing
      #assert_match(/#{METAR_CITY}/, metar)
      #assert_nil ma.exception

      if metar.nil?
        puts "#{k} - site show nil"
      else
        assert_match(/#{METAR_CITY}/, metar)
      end

    end

    #    mb = MetarRipperAviationWeather.new
    #    metar = ma.fetch( METAR_CITY )
    #
    #    assert_match(/#{METAR_CITY}/, metar)
    #    assert_nil ma.exception

  end

  def test_full
    m = MetarRipper.instance
    o = m.fetch('EPPO')
    puts o.inspect
  end

end

