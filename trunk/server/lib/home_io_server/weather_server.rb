require "weather_fetcher"
require "home_io_server/weather_fetcher_addons/weather_data"
require "yaml"

require 'home_io_server/weather_server/weather_buffer.rb'

# Server fetching weather

module HomeIoServer
  class WeatherServer

    CRON_LIKE = true
    UNDER_DEVELOPMENT = true

    def initialize
      @weathers = Hash.new

      @config = YAML.load(File.open("config/weather.yml"))

      # setting API key
      begin
        secret = YAML.load(File.open("config/weather_secret.yml"))
        @config.merge!(secret)
        WeatherFetcher::Provider::WorldWeatherOnline.api = @config[:common]["WorldWeatherOnline"][:key]
      rescue
        # nothing
      end

      @config[:cities] = @config[:cities][0..5] if UNDER_DEVELOPMENT # UNDER_DEVELOPMENT
      @cities = @config[:cities]
      # for storing all weathers in one batch
      @current_weathers = Array.new

      # db init
      Storage.instance
      initialize_db

      if CRON_LIKE
        #first loop, nobody wants to wait
        fetch_loop

        @scheduler = Rufus::Scheduler.start_new
        @scheduler.every '2s' do # UNDER_DEVELOPMENT
          fetch_loop
        end
      else
        loop do
          fetch_loop
          sleep 5*60
        end
      end

    end

    def initialize_db
      @cities.each do |city|
        ar_city = City.where(name: city[:name]).where(country: city[:country]).first
        unless ar_city
          city_hash = city
          city_hash.delete(:classes)
          ar_city = City.new(city_hash)
          ar_city.save! # TODO some exception handling
        end
        city[:id] = ar_city.id
      end
    end

    def fetch_loop
      @cities.each do |city|
        WeatherBuffer.instance.fetch_city(city)
      end
      WeatherBuffer.instance.flush_storage_buffer
    end

  end
end