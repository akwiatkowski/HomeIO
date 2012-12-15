Factory.define :weather_metar_archive do |m|
  m.sequence(:time_from) { |n| Time.now - 1.hours - 30 * n.minutes }
  m.sequence(:time_to) { |n| Time.now - 30.minutes - 30 * n.minutes }

  m.temperature 5.0
  m.wind 1.0
  m.pressure 1000.0
  m.rain_metar 0
  m.snow_metar 0

  m.association :city

  m.sequence(:raw) { |n| "CITY #{n}" }
end