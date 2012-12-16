require "weather_fetcher"
require "yaml"

require "home_io_server/weather_fetcher_addons/weather_data"
require 'home_io_server/weather_server/weather_buffer.rb'

# Server fetching weather

module HomeIoServer
  class WeatherServer

    CRON_LIKE = true
    INTERVAL = 5 # minutes
    CONFIG_PATH = File.join("config", "backend", "weather.yml")
    CONFIG_SECRET_PATH = File.join("config", "backend", "weather_secret.yml")

    def initialize
      @logger = HomeIoLogger.l('weather_server')
      @weathers = Hash.new
      @config = YAML.load(File.open(CONFIG_PATH))

      # setting API key
      begin
        secret = YAML.load(File.open(CONFIG_SECRET_PATH))
        @config.merge!(secret)
        WeatherFetcher::Provider::WorldWeatherOnline.api = @config[:common]["WorldWeatherOnline"][:key]
      rescue => e
        @logger.info("WorldWeatherOnline is not available")
      end

      if WeatherFetcher::Provider::WorldWeatherOnline.api
        @logger.debug("Using api key for WorldWeatherOnline")
      end

      # @config[:cities] = @config[:cities][0..2]
      @cities = @config[:cities]
      @logger.debug("Number of cities #{@cities.size}")
      # for storing all weathers in one batch
      @current_weathers = Array.new

      # db init
      Storage.instance
      initialize_db
      @logger.debug("DB connection ready")

      @iteration = 0
    end

    def dev_mode!
      #@cities = @cities[0..3]
      @cities = [@cities.first]
    end

    def start
      if CRON_LIKE
        @logger.debug("Using scheduler")
        #first loop, nobody wants to wait
        fetch_loop

        @scheduler = Rufus::Scheduler.start_new
        @scheduler.every "#{INTERVAL}m" do
          fetch_loop
        end
      else
        @logger.debug("Using loop-sleep")
        loop do
          fetch_loop
          sleep INTERVAL * 60
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
      @logger.debug("Starting loop".yellow.on_red)
      ta = Time.now

      @cities.each do |city|
        WeatherBuffer.instance.fetch_city(city)
      end

      @logger.debug("Weather fetched")
      tb = Time.now

      WeatherBuffer.instance.flush_storage_buffer

      @logger.debug("Weather stored")
      tc = Time.now

      @iteration += 1
      @logger.info("Fetch time cost #{(tb-ta).to_s.light_blue}, store time cost #{(tc-tb).to_s.light_blue}, total cost #{(tc-ta).to_s.light_blue}, iteration #{@iteration}")
    end

  end
end