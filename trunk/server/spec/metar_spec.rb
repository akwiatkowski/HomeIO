require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

sample_metar = "LBBG 041600Z 12003MPS 310V290 1400 R04/P1500N R22/P1500U +SN BKN022 OVC050 M04/M07 Q1020 NOSIG 9949//91="

describe "SimpleMetarParser::Metar" do
  it "simple test" do
    m = SimpleMetarParser::Parser.parse(sample_metar)
    m.raw.should == sample_metar
  end

  it "should hold up with empty string and be invalid" do
    m = SimpleMetarParser::Parser.parse('')
    m.valid?.should_not
  end

  it "should get city information using fake AR class" do
    # fake class
    class FakeCity
      def self.find_by_metar(m)
        return {:city => m}
      end
    end

    SimpleMetarParser::Metar.rails_model = FakeCity
    m = SimpleMetarParser::Parser.parse(sample_metar)
    m.city.model.should == FakeCity.find_by_metar('LBBG')

    SimpleMetarParser::Metar.rails_model = nil
    m = SimpleMetarParser::Parser.parse(sample_metar)
    m.city.model.should == nil
  end

  it "change time range" do
    time_range = SimpleMetarParser::Metar::DEFAULT_TIME_INTERVAL
    m = SimpleMetarParser::Parser.parse(sample_metar)
    m.time.time_interval.should == time_range
    m.time_from.should == m.time_to - time_range
    m.time.time_from.should == m.time.time_from
    m.time.time_to.should == m.time.time_to

    time_range = 3600
    m = SimpleMetarParser::Parser.parse(sample_metar, {:time_interval => time_range})
    m.time.time_interval.should == time_range
    m.time_from.should == m.time_to - time_range
  end

  it "decode metar string (1)" do
    # http://www.metarreader.com/
    
    metar_string = "LBBG 041600Z 12003MPS 310V290 1400 R04/P1500N R22/P1500U +SN BKN022 OVC050 M04/M07 Q1020 NOSIG 9949//91="

    m = SimpleMetarParser::Parser.parse(metar_string)
    m.time_from.utc.day.should == 4
    m.time_from.utc.hour.should == 16
    m.time_from.utc.min.should == 0

    (m.time_to - m.time_from).should == 30*60

    m.city.should be_kind_of(SimpleMetarParser::MetarCity)
    m.city.code == "LBBG"

    m.wind.should be_kind_of(SimpleMetarParser::Wind)
    m.wind.wind_direction.should == 120
    m.wind.wind_speed.should == 3
    m.wind.wind_speed_kmh.should be_within(0.05).of(3 * 3.6)
    m.wind.mps.should == 3
    m.wind.kmh.should be_within(0.05).of(3 * 3.6)
    m.wind.knots.should_not == nil
    m.wind.direction.should == 120

    m.temperature.should be_kind_of(SimpleMetarParser::Temperature)
    m.temperature.temperature.should == -4
    m.temperature.dew.should == -7
    m.temperature.humidity.should == 80
    m.temperature.wind_chill.should_not == nil
    m.temperature.wind_chill_us.should_not == nil
    m.temperature.degrees.should == -4

    m.pressure.should be_kind_of(SimpleMetarParser::Pressure)
    m.pressure.pressure.should == 1020
    m.pressure.hpa.should == 1020
    m.pressure.hg_mm.should_not == nil
    m.pressure.hg_inch.should_not == nil

    m.visibility.should be_kind_of(SimpleMetarParser::Visibility)
    m.visibility.visibility.should == 1400

    m.clouds.should be_kind_of(SimpleMetarParser::Clouds)
    m.clouds.clouds.should be_kind_of(Array)
    m.clouds.clouds.size.should == 2
    m.clouds.clouds_max.should == 100

    m.specials.should be_kind_of(SimpleMetarParser::MetarSpecials)
    m.specials.specials.should be_kind_of(Array)
    m.specials.specials.size.should == 1

    #puts m.other.station
    #puts m.other.station_auto
  end

  it "decode metar string (2)" do
    # http://www.metarreader.com/

    metar_string = "KTTN 051853Z 04011KT 1/2SM VCTS SN FZFG BKN003 OVC010 M02/M02 A3006 RMK AO2 TSB40 SLP176 P0002 T10171017="

    m = SimpleMetarParser::Parser.parse(metar_string)
    m.time_from.utc.day.should == 5
    m.time_from.utc.hour.should == 18
    m.time_from.utc.min.should == 53

    (m.time_to - m.time_from).should == 30*60

    m.city.code == "KTTN"

    m.wind.should be_kind_of(SimpleMetarParser::Wind)
    m.wind.wind_direction.should == 40
    m.wind.wind_speed_knots.should == 11

    m.temperature.temperature.should == -2
    m.temperature.dew.should == -2
    m.temperature.humidity.should == 100
    #m.temperature.wind_chill.should == -8 # ?

    m.pressure.pressure.should == 1018

    # http://www.flightutilities.com/MRonline.aspx
    m.visibility.visibility.should == 800

    m.clouds.clouds.size.should == 2
    m.clouds.clouds_max.should == 100

    m.specials.specials.size.should == 3
  end

  it "calculate snow amount using some weird algorithm" do
    metar_string = "KTTN 051853Z 04011KT 1/2SM VCTS SN FZFG BKN003 OVC010 M02/M02 A3006 RMK AO2 TSB40 SLP176 P0002 T10171017="
    m = SimpleMetarParser::Parser.parse(metar_string)
    snow_normal = m.specials.snow_metar

    metar_string = "KTTN 051853Z 04011KT 1/2SM VCTS -SN FZFG BKN003 OVC010 M02/M02 A3006 RMK AO2 TSB40 SLP176 P0002 T10171017="
    m = SimpleMetarParser::Parser.parse(metar_string)
    snow_light = m.specials.snow_metar

    metar_string = "KTTN 051853Z 04011KT 1/2SM VCTS +SN FZFG BKN003 OVC010 M02/M02 A3006 RMK AO2 TSB40 SLP176 P0002 T10171017="
    m = SimpleMetarParser::Parser.parse(metar_string)
    snow_heavy = m.specials.snow_metar

    snow_normal.should > snow_light
    snow_heavy.should > snow_normal
  end

  it "parse runway information" do
    metar_string = "LBBG 041600Z 12003MPS 310V290 1400 R04/P1500N R22/P1500U +SN BKN022 OVC050 M04/M07 Q1020 NOSIG 9949//91="
    m = SimpleMetarParser::Parser.parse(metar_string)
    m.runway.runways.should be_kind_of(Array)
    m.runway.runways.size.should == 2

    m.runway.runways.should =~ [
      {:runway => '04', :visual_range => 1_500},
      {:runway => '22', :visual_range => 1_500, :change => :up}
    ]

  end

end
