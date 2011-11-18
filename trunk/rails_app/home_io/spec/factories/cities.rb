Factory.define :city do |m|
  m.sequence(:name) { |n| n || "city_" + Time.now.usec.to_s }
  m.sequence(:country) {|n| n || "Country" }
  m.sequence(:metar) {|n| n.nil? ? nil : n }
  m.sequence(:lat) {|n| n || Time.now.to_f % 60.0 }
  m.sequence(:lon) {|n| n || Time.now.to_f % 60.0 }
  m.sequence(:calculated_distance) {|n| n || 10.0 }

  m.sequence(:logged_metar) {|n| n.nil? ? false : n }
  m.sequence(:logged_weather) {|n| n.nil? ? false : n }
end