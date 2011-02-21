# ruby-prof -p call_tree -f cache.cache test/profile/profile_weather.rb

require 'lib/weather_ripper'
w = WeatherRipper.instance
w.fetch