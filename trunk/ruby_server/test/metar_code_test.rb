# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'metar_code'

class MetarCodeTest < Test::Unit::TestCase
  def test_validity
    wrong_metar_a = "przestarzały (2250 godziny)"
    wrong_metar_b = "brakujący"
    wrong_metar_c = "CWGZ NIL"

    good_metar = "2010/08/15 05:00 CXAT 150500Z AUTO 31009KT 04/03 RMK AO1 6PAST HR 3001 P0002 T00370033 50006 "

    mc = MetarCode.new
    mc.process(wrong_metar_a, 2010, 11)
    assert_equal false, mc.valid?

    mc = MetarCode.new
    mc.process(wrong_metar_b, 2010, 11)
    assert_equal false, mc.valid?

    mc = MetarCode.new
    mc.process(wrong_metar_c, 2010, 11)
    assert_equal false, mc.valid?

    mc = MetarCode.new
    mc.process(good_metar, 2010, 11)
    assert_equal true, mc.valid?
  end

  def test_metar_a
    good_metar = "2010/08/15 05:00 CXAT 150500Z AUTO 31009KT 04/03 RMK AO1 6PAST HR 3001 P0002 T00370033 50006 "

    mc = MetarCode.new
    mc.process(good_metar, 2010, 11)
    assert_equal true, mc.valid?

    assert_equal 'CXAT', mc.output[:city]

    # time
    # metars don't need to have '2010/08/15'
    #assert_equal 2010, mc.year
    #assert_equal 8, mc.month
    #assert_equal 2010, mc.output[:time].year
    #assert_equal 8, mc.output[:time].month

    assert_equal 15, mc.output[:time].day
    assert_equal 5, mc.output[:time].hour
    assert_equal 0, mc.output[:time].min

    # wind
    assert_equal 9 * 1.85, mc.output[:wind]
    assert_equal 310, mc.output[:wind_direction]

    # temperature
    assert_equal 4, mc.output[:temperature]
    assert_equal 3, mc.output[:temperature_dew]

    # metar without pressure
    assert_equal nil, mc.output[:pressure]

    # euro-like visiblity
    assert_equal 3001, mc.output[:visiblity]

    # no clouds info
    assert_equal nil, mc.output[:clouds]
    assert_equal nil, mc.output[:clouds_bottom]

    assert_kind_of Array, mc.output[:specials]

    

  end

  def test_metar_b
    good_metar = "EPPO 171800Z 04007KT 1400 R29/P2000 -DZ BR BKN002 06/06 Q1011"

    mc = MetarCode.new
    mc.process(good_metar, 2010, 11)
    assert_equal true, mc.valid?

    assert_equal 'EPPO', mc.output[:city]

    # time
    # metars don't need to have '2010/08/15'
    #assert_equal 2010, mc.year
    #assert_equal 8, mc.month
    #assert_equal 2010, mc.output[:time].year
    #assert_equal 8, mc.output[:time].month

    assert_equal 17, mc.output[:time].day
    assert_equal 18, mc.output[:time].hour
    assert_equal 0, mc.output[:time].min

    # wind
    assert_equal 7 * 1.85, mc.output[:wind]
    assert_equal 40, mc.output[:wind_direction]

    # temperature
    assert_equal 6, mc.output[:temperature]
    assert_equal 6, mc.output[:temperature_dew]

    # metar pressure
    assert_equal 1011, mc.output[:pressure]

    # euro-like visiblity
    assert_equal 1400, mc.output[:visiblity]

    # clouds info
    assert_equal 75, mc.output[:clouds]
    assert_equal 2 * 30, mc.output[:clouds_bottom]

    assert_kind_of Array, mc.output[:specials]
    # specials
    assert_not_nil mc.output[:specials].select{|s| s[:obscuration] == "mist"}.first
    assert_not_nil mc.output[:specials].select{|s| s[:precipitation] == "drizzle" and s[:intensity] == "light" }.first


  end

end
