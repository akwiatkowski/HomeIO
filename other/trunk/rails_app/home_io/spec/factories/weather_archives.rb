Factory.define :weather_archive do |m|
  m.sequence(:time_from) { |n| Time.now - 2.hours - n.minutes }
  m.sequence(:time_to) { |n| Time.now - 1.hour - n.minutes }

  m.temperature 5.0
  m.wind 1.0
  m.pressure 1000.0
  m.rain 0.0
  m.snow 0.0
  
  m.association :city
  m.association :weather_provider
end