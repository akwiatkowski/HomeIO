Factory.define :weather_provider do |m|
  m.sequence(:name) { |n| "weather_provider_" + n.to_s }
end