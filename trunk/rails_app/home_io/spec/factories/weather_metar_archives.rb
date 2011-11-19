Factory.define :weather_metar_archive do |m|
  m.time_from Time.now - 1.hours
  m.time_to Time.now - 30.minutes

  m.temperature 5.0
  m.wind 1.0
  m.pressure 1000.0
  m.rain_metar 0
  m.snow_metar 0

  m.association :city

  m.raw 'CITY '
end