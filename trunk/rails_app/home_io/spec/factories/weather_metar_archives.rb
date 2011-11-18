Factory.define :weather_metar_archive do |m|
  m.sequence(:time_from) { |n| n || Time.now - 1.hours }
  m.sequence(:time_to) { |n| n || Time.now - 30.minutes }

  m.sequence(:temperature) {|n| n || 5.0 }
  m.sequence(:wind) {|n| n || 1.0 }
  m.sequence(:pressure) {|n| n || 1000.0 }
  m.sequence(:rain_metar) {|n| n || 0 }
  m.sequence(:snow_metar) {|n| n || 0 }

  m.sequence(:raw) {|n| n || 'CITY ' }

  m.sequence(:city_id) {|n| n }
end