require 'singleton'
require './lib/utils/config_loader.rb'

require './lib/weather_ripper/weather_onet_pl.rb'
require './lib/weather_ripper/weather_wp_pl.rb'
require './lib/weather_ripper/weather_interia_pl.rb'

# Fetch weather information from various web pages (mainly polish ones)
class WeatherRipper
  include Singleton

  attr_reader :providers

  # weather raw logs are stored here
  WEATHER_DIR = File.join(
    Constants::DATA_DIR,
    'weather'
  )

  def initialize
    prepare_directories

    @@config = ConfigLoader.instance.config( self.class )

    @providers = [
      #WeatherOnetPl.new, # TODO big changes
      WeatherWpPl.new,
      WeatherInteriaPl.new
    ]

    (0...(@providers.size)).each do |i|
      @providers[i].id = i + 1
    end

    puts "#{self.class.to_s} init - #{@providers.size} providers"

  end

  # Fetch weather from all providers, and all cities
  def fetch
    WeatherCityProxy.instance.post_init

    @providers.each do |p|
      p.check_all
    end
    return {:status => :ok}
  end

  # Fetch weather from all providers, and all cities
  def start
    fetch
  end

  private

  def prepare_directories
    if not File.exists?( Constants::DATA_DIR )
      Dir.mkdir( Constants::DATA_DIR )
    end

    if not File.exists?( WEATHER_DIR )
      Dir.mkdir( WEATHER_DIR )
    end
  end
end
