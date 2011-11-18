Factory.define :weather_provider do |m|
  m.sequence(:name) { |n| n || "weather_provider_" + Time.now.usec.to_s }
end