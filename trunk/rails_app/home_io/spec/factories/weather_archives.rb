Factory.define :weather_archive do |m|
  m.sequence(:time_from) { |n| n || Time.now - 2.hours }
  m.sequence(:time_to) { |n| n || Time.now - 1.hour }

  m.sequence(:temperature) {|n| n || 5.0 }
  m.sequence(:wind) {|n| n || 1.0 }
  m.sequence(:pressure) {|n| n || 1000.0 }
  m.sequence(:rain) {|n| n || 0.0 }
  m.sequence(:snow) {|n| n || 0.0 }
  
  m.sequence(:city_id) {|n| n }
  m.sequence(:weather_provider_id) {|n| n }
end