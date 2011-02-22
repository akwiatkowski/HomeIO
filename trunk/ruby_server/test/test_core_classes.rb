require 'lib/utils/core_classes'
require 'test/unit'

class TestCoreClasses < Test::Unit::TestCase

  def test_string
    str = "RJTT 160530Z 36011KT 9999 FEW030 SCT050 BKN/// 14/M01 Q1003 RMK 1CU030 3SC050 A2964 MOD TURB BTN 10000 AND 7000FT OVER TATEYAMA BY A320 AT 0505 AND BTN 11000 AND 10000FT 10NM N TATEYAMA BY B777 AT 0512 AND BTN 10000 AND 9000FT OVER TATEYAMA BY B777 AT 0525"

    [200, 100, 40, 10, 8].each do |l|
      assert str.shorten_in_whitespace(l).length < l
    end
  end

end

