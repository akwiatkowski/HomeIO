require "weather_fetcher"
require "yaml"

# Server fetching weather

module HomeIoServer
  class WeatherServer

    def initialize
      @weathers = Hash.new

      @config = YAML.load(File.open("config/weather.yml"))
      secret = YAML.load(File.open("config/weather_secret.yml"))
      @config.merge!(secret)

      @config[:cities] = @config[:cities][0..2]

      WeatherFetcher::Provider::WorldWeatherOnline.api = @config[:common]["WorldWeatherOnline"][:key]

      #loop do
      #  fetch_loop
      #  sleep 2
      #end

      @scheduler = Rufus::Scheduler.start_new
      @scheduler.every '15m' do
        fetch_loop
      end
    end

    def fetch_loop
      @config[:cities].each do |city|
        fetch_for_city(city)
      end
    end

    def fetch_for_city(_city)
      begin
        @weathers[_city] ||= Array.new # init
        providers = WeatherFetcher::SchedulerHelper.recommended_providers(@weathers[_city])
        puts providers.inspect, @weathers[_city].collect { |w| w.provider }.inspect

        providers.each do |provider|
          p_i = provider.new(_city)
          p_i.fetch
          new_weathers = p_i.weathers

          store_weather(new_weathers, _city)

          @weathers[_city] += new_weathers
          @weathers[_city].uniq!
        end

        puts "#{_city[:name]} - #{@weathers[_city].size}"
        @weathers[_city].uniq!
        puts "#{_city[:name]} - #{@weathers[_city].size} UNIQ"
      rescue
        puts _city.inspect
        puts "#{_city[:name]} - FAIL"
      end
    end

    def store_weather(data, city)
      puts "Storing #{data.size} records for city #{city[:name]} :)"
    end

  end
end