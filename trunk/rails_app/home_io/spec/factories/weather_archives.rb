Factory.define :weather_archive do |m|
  m.time_from Time.now - 2.hours
  m.time_to Time.now - 1.hour

  m.temperature 5.0
  m.wind 1.0
  m.pressure 1000.0
  m.rain 0.0
  m.snow 0.0
  
  m.association :city
  m.association :weather_provider
end