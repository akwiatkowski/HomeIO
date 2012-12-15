require 'tools/weather_grapher/weather_grapher'

metars = [
  "NZSP",
  "UHPP",
  "RJTT",
  "UHHH",
  "CYVR",
  "KPDX",
  "KNYC",
  "EGLL",
  "KRMG",
  "OMDB",
  "KLAX",
  "HECA",
  "EPWA",
  "EPKT",
  "EPKK",
  "EFIV",
  "GMML",
  "PHNL",
  "NZCM",
  "CXAT",
  "BGQQ",
  "CWGZ",
  "CWEU",
  "VNKT",
  "EFHK",
  "EFOU",
  "UOHH",
  "UOOO",
  "UEST",
  "ULLI",
  "NSTU",
  "AGGH",
  "UKCW",
  "GVSV",
  "LSZS",
  "ENBJ",
  "ENDU",
  "ENHE",
  "ENHF",
  "ENHV",
  "ENKR",
  "EHDV",
  "EHKV",
  "EGPB",
  "BIAR",
  "PWAK",
  'EPPO'
]

years = [2011, 2010, 2009]

years.each do |y|
  metars.each do |m|
    begin
      WeatherGrapher.metar_city_year(m, y)
    rescue => e
      puts "Error"
      puts e.inspect
      puts e.backtrace
    end
  end
end

