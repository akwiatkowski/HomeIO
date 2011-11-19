Factory.define :city do |m|
  m.sequence(:name) { |n| "city_" + n.to_s }
  m.sequence(:country) {|n| "Country" + n.to_s }
  m.metar nil
  m.lat 60.0 + Time.now.usec % 5.0 + rand(10).to_f / 10.0
  m.lon 60.0 + Time.now.usec % 5.0 + rand(10).to_f / 10.0
  m.calculated_distance 10.0 + Time.now.usec % 3.0 + rand(4).to_f / 10.0

  m.logged_metar false
  m.logged_weather false
end