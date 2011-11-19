Factory.define :city do |m|
  m.sequence(:name) { |n| "city_" + n.to_s }
  m.sequence(:country) {|n| "Country" + n.to_s }
  m.metar nil

  m.sequence(:lat) { |n| 30.0 + Math.sin(n.to_f / 10.0) * 20.0 }
  m.sequence(:lon) { |n| 27.0 + Math.sin(n.to_f / 9.0 + 0.2) * 19.0 }
  m.sequence(:calculated_distance) { |n| 100.0 + n.to_f * 10.0 }

  m.logged_metar false
  m.logged_weather false
end