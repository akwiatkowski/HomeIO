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

  # some random metars - conversion
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
    assert_equal [], mc.output[:clouds]
    assert_equal 0, mc.output[:clouds].size

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
    assert_equal 1, mc.output[:clouds].size
    assert_equal 1, mc.output[:clouds].select{|c| c[:coverage] == 75 and c[:bottom] == 2 * 30 }.size

    assert_kind_of Array, mc.output[:specials]
    # specials
    assert_not_nil mc.output[:specials].select{|s| s[:obscuration] == "mist"}.first
    assert_not_nil mc.output[:specials].select{|s| s[:precipitation] == "drizzle" and s[:intensity] == "light" }.first


  end

  def test_metar_c
    good_metar = "NZSP 151250Z 11005KT 9999 FEW020 SCT060 M42/ A2830 RMK CLN AIR 11004KT ALL WNDS GRID SDG/HDG"

    mc = MetarCode.new
    mc.process(good_metar, 2010, 11)
    assert_equal true, mc.valid?

    assert_equal 'NZSP', mc.output[:city]

    # time
    # metars don't need to have '2010/08/15'
    #assert_equal 2010, mc.year
    #assert_equal 8, mc.month
    #assert_equal 2010, mc.output[:time].year
    #assert_equal 8, mc.output[:time].month

    assert_equal 15, mc.output[:time].day
    assert_equal 12, mc.output[:time].hour
    assert_equal 50, mc.output[:time].min

    # wind
    assert_equal 5 * 1.85, mc.output[:wind]
    assert_equal 110, mc.output[:wind_direction]

    # temperature
    assert_equal -42, mc.output[:temperature]
    assert_equal nil, mc.output[:temperature_dew]

    # max visiblity
    assert_equal MetarCode::MAX_VISIBLITY, mc.output[:visiblity]


    # metar pressure
    assert_in_delta 2830.to_f * 1018.0 / 3006, mc.output[:pressure], 2.0

    # clouds info
    assert_kind_of Array, mc.output[:clouds]
    assert_equal 2, mc.output[:clouds].size
    #puts mc.output[:clouds].inspect
    assert_equal 1, mc.output[:clouds].select{|c| c[:coverage] == (1.5 * 100.0 / 8.0).round and c[:bottom] == 20 * 30 }.size
    assert_equal 1, mc.output[:clouds].select{|c| c[:coverage] == (3.5 * 100.0 / 8.0).round and c[:bottom] == 60 * 30 }.size


    assert_kind_of Array, mc.output[:specials]
    # specials - no specials
    assert_nil mc.output[:specials].select{|s| s[:obscuration] == "mist"}.first
    assert_nil mc.output[:specials].select{|s| s[:precipitation] == "drizzle" and s[:intensity] == "light" }.first
    assert_equal [], mc.output[:specials]


  end

  def test_metar_d
    good_metar = "BIAR 130700Z 17003KT 0350 R01/0900V1500U +SN VV001 M04/M04 Q0996"

    mc = MetarCode.new
    mc.process(good_metar, 2010, 11)
    assert_equal true, mc.valid?

    assert_equal 'BIAR', mc.output[:city]

    # time
    # metars don't need to have '2010/08/15'
    #assert_equal 2010, mc.year
    #assert_equal 8, mc.month
    #assert_equal 2010, mc.output[:time].year
    #assert_equal 8, mc.output[:time].month

    assert_equal 13, mc.output[:time].day
    assert_equal 7, mc.output[:time].hour
    assert_equal 0, mc.output[:time].min

    # wind
    assert_equal 3 * 1.85, mc.output[:wind]
    assert_equal 170, mc.output[:wind_direction]

    # temperature
    assert_equal -4, mc.output[:temperature]
    assert_equal -4, mc.output[:temperature_dew]

    # max visiblity
    assert_equal 350, mc.output[:visiblity]

    # metar pressure
    #assert_in_delta 2830.to_f * 1018.0 / 3006, mc.output[:pressure], 2.0
    assert_equal 996, mc.output[:pressure]

    # clouds info
    assert_kind_of Array, mc.output[:clouds]
    assert_equal 1, mc.output[:clouds].size
    #puts mc.output[:clouds].inspect
    assert_equal 1, mc.output[:clouds].select{|c| c[:coverage] == 100 and c[:bottom] == nil and c[:vertical_visiblity] == 30 }.size
    assert_equal 0, mc.output[:clouds].select{|c| c[:coverage] == (3.5 * 100.0 / 8.0).round and c[:bottom] == 60 * 30 }.size

    # specials
    assert_kind_of Array, mc.output[:specials]
    assert_not_equal [], mc.output[:specials]
    assert_nil mc.output[:specials].select{|s| s[:obscuration] == "mist"}.first
    assert_nil mc.output[:specials].select{|s| s[:precipitation] == "drizzle" and s[:intensity] == "light" }.first
    assert_equal 1, mc.output[:specials].select{|s| s[:intensity] == "heavy" and s[:precipitation] == "snow" }.size
    


  end

  def test_metar_e
    good_metar = "KRMG 021153Z AUTO 10006KT 10SM BKN060 OVC070 14/06 A3024 RMK AO2 SLP236 T01390061 10144 20117 51007"

    mc = MetarCode.new
    mc.process(good_metar, 2010, 11)
    assert_equal true, mc.valid?

    assert_equal 'KRMG', mc.output[:city]

    # time
    # metars don't need to have '2010/08/15'
    #assert_equal 2010, mc.year
    #assert_equal 8, mc.month
    #assert_equal 2010, mc.output[:time].year
    #assert_equal 8, mc.output[:time].month

    assert_equal 2, mc.output[:time].day
    assert_equal 11, mc.output[:time].hour
    assert_equal 53, mc.output[:time].min

    # wind
    assert_equal 6 * 1.85, mc.output[:wind]
    assert_equal 100, mc.output[:wind_direction]

    # temperature
    assert_equal 14, mc.output[:temperature]
    assert_equal 6, mc.output[:temperature_dew]

    # max visiblity
    assert_equal MetarCode::MAX_VISIBLITY, mc.output[:visiblity]

    # metar pressure
    assert_in_delta 3024.to_f * 1018.0 / 3006, mc.output[:pressure], 2.0
    #assert_equal 996, mc.output[:pressure]

    # clouds info
    assert_kind_of Array, mc.output[:clouds]
    assert_equal 2, mc.output[:clouds].size
    #puts mc.output[:clouds].inspect
    assert_equal 1, mc.output[:clouds].select{|c| c[:coverage] == (6 * 100.0 / 8.0).round and c[:bottom] == 60 * 30 }.size
    assert_equal 1, mc.output[:clouds].select{|c| c[:coverage] == (8 * 100.0 / 8.0).round and c[:bottom] == 70 * 30 }.size

    # specials
    assert_kind_of Array, mc.output[:specials]
    assert_equal [], mc.output[:specials]
  end

  def test_metar_f
    good_metar = "OMDB 060500Z 17006KT 140V210 8000 NSC 36/14 Q1004 NOSIG"

    mc = MetarCode.new
    mc.process(good_metar, 2010, 11)
    assert_equal true, mc.valid?

    assert_equal 'OMDB', mc.output[:city]

    # time
    # metars don't need to have '2010/08/15'
    #assert_equal 2010, mc.year
    #assert_equal 8, mc.month
    #assert_equal 2010, mc.output[:time].year
    #assert_equal 8, mc.output[:time].month

    assert_equal 6, mc.output[:time].day
    assert_equal 5, mc.output[:time].hour
    assert_equal 0, mc.output[:time].min

    # wind
    assert_equal 6 * 1.85, mc.output[:wind]
    assert_equal 170, mc.output[:wind_direction]

    # temperature
    assert_equal 36, mc.output[:temperature]
    assert_equal 14, mc.output[:temperature_dew]

    # max visiblity
    assert_equal 8000, mc.output[:visiblity]

    # metar pressure
    #assert_in_delta 3024.to_f * 1018.0 / 3006, mc.output[:pressure], 2.0
    assert_equal 1004, mc.output[:pressure]

    # clouds info
    assert_kind_of Array, mc.output[:clouds]
    assert_equal 0, mc.output[:clouds].size
    #puts mc.output[:clouds].inspect
    #assert_equal 1, mc.output[:clouds].select{|c| c[:coverage] == (6 * 100.0 / 8.0).round and c[:bottom] == 60 * 30 }.size
    #assert_equal 1, mc.output[:clouds].select{|c| c[:coverage] == (8 * 100.0 / 8.0).round and c[:bottom] == 70 * 30 }.size

    # specials
    assert_kind_of Array, mc.output[:specials]
    assert_equal [], mc.output[:specials]
  end

  def test_metar_g
    good_metar = "PHNL 151953Z 07009KT 10SM FEW026 SCT035 BKN070 25/21 A3010 RMK AO2 RAE06 SLP192 VCSH OMTNS N-NE AND E-SE P0000 T02500206"

    mc = MetarCode.new
    mc.process(good_metar, 2010, 11)
    assert_equal true, mc.valid?

    assert_equal 'PHNL', mc.output[:city]

    # time
    # metars don't need to have '2010/08/15'
    #assert_equal 2010, mc.year
    #assert_equal 8, mc.month
    #assert_equal 2010, mc.output[:time].year
    #assert_equal 8, mc.output[:time].month

    assert_equal 15, mc.output[:time].day
    assert_equal 19, mc.output[:time].hour
    assert_equal 53, mc.output[:time].min

    # wind
    assert_equal 9 * 1.85, mc.output[:wind]
    assert_equal 70, mc.output[:wind_direction]

    # temperature
    assert_equal 25, mc.output[:temperature]
    assert_equal 21, mc.output[:temperature_dew]

    # max visiblity
    assert_equal MetarCode::MAX_VISIBLITY, mc.output[:visiblity]

    # metar pressure
    assert_in_delta 3004.to_f * 1018.0 / 3006, mc.output[:pressure], 2.0
    #assert_equal 1004, mc.output[:pressure]

    # clouds info
    assert_kind_of Array, mc.output[:clouds]
    assert_equal 3, mc.output[:clouds].size
    #puts mc.output[:clouds].inspect
    assert_equal 1, mc.output[:clouds].select{|c| c[:coverage] == (1.5 * 100.0 / 8.0).round and c[:bottom] == 26 * 30 }.size
    assert_equal 1, mc.output[:clouds].select{|c| c[:coverage] == (3.5 * 100.0 / 8.0).round and c[:bottom] == 35 * 30 }.size
    assert_equal 1, mc.output[:clouds].select{|c| c[:coverage] == (6 * 100.0 / 8.0).round and c[:bottom] == 70 * 30 }.size

    # specials
    # TODO
    #assert_kind_of Array, mc.output[:specials]
    #assert_equal 1, mc.output[:specials].size
  end



end
