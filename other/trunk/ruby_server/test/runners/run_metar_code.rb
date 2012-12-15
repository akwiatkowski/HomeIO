require File.join Dir.pwd, 'lib/metar/metar_code'
good_metar = "2010/08/15 05:00 CXAT 150500Z AUTO 31009KT 04/03 RMK AO1 6PAST HR 3001 P0002 T00370033 50006 "
mc = MetarCode.new
mc.process_archived(good_metar, 2010, 11)
puts mc.to_yaml
puts mc.city_metar