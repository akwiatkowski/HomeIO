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

  def test_common_parameters
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


    

  end
end
