require "weather_fetcher"
require "home_io_server/weather_fetcher_addons/weather_data"
require "yaml"

require 'home_io_server/weather_server/weather_backup_storage.rb'

# Server fetching weather

module HomeIoServer
  class WeatherServer

    CRON_LIKE = true

    def initialize
      @weathers = Hash.new

      @config = YAML.load(File.open("config/weather.yml"))
      secret = YAML.load(File.open("config/weather_secret.yml"))
      @config.merge!(secret)

      #@config[:cities] = @config[:cities][-15..-1]
      @cities = @config[:cities]

      WeatherFetcher::Provider::WorldWeatherOnline.api = @config[:common]["WorldWeatherOnline"][:key]

      Storage.instance
      initialize_db

      if CRON_LIKE
        #first loop, nobody wants to wait
        fetch_loop

        @scheduler = Rufus::Scheduler.start_new
        @scheduler.every '15m' do
          fetch_loop
        end
      else
        loop do
          fetch_loop
          sleep 15*60
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
        fetch_for_city(city)
      end
    end

    def fetch_for_city(_city)
      @weathers[_city] ||= Array.new # init
      providers = WeatherFetcher::SchedulerHelper.recommended_providers(@weathers[_city])

      providers.each do |provider|
        p_i = provider.new(_city)
        begin
        p_i.fetch
        rescue => ex
          puts "*"*1000
          puts _city.inspect
          puts provider
          puts "#{ex.backtrace}: #{ex.message} (#{ex.class})"
          exit!
        end
        new_weathers = p_i.weathers

        store_weather(new_weathers)

        @weathers[_city] += new_weathers
        @weathers[_city].uniq!
      end

      puts "#{_city[:name]} - #{@weathers[_city].size}"
      #@weathers[_city].uniq!
      #puts "#{_city[:name]} - #{@weathers[_city].size} UNIQ"
    end

    def store_weather(data)
      WeatherBackupStorage.instance.store(data)
      data.each do |wd|
        ar = wd.to_ar
        puts ar.inspect unless ar.valid? # TODO ingoring bad objects
        ar.save
      end
      #puts "Storing #{data.size} records for city #{city[:name]} :)"
    end

  end
end