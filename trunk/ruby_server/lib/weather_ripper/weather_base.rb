require 'net/http'
require 'rubygems'
require 'hpricot'
require './lib/storage/storage.rb'
require './lib/utils/adv_log.rb'
require './lib/weather_ripper.rb'
require './lib/weather_ripper/utils/weather_city_proxy.rb'
require './lib/weather_ripper/weather.rb'


class WeatherBase

  attr_reader :defs

  # Id used in DB
  attr_accessor :id

  def initialize
    @config = ConfigLoader.instance.config( self.class )
    @defs = @config[:defs]
  end

  # Safec accesor
  #attr_reader :config
  def config
    return @config.clone
  end

  # Check weather for all configured cities
  def check_all
    @defs.each do |d|
      
      begin
        check_online( d )
      rescue => e
        # log errors using standarized method
        log_error( self, e )
        # when set it blow up everything to pieces :]
        if true == @config[:stop_on_error]
          raise e
        end
      end
    end
    # must have!
    Storage.instance.flush
  end

  def process( body_raw )
    raise 'Not implemented'

    # this method should return Array of Hashes like this
    # [{
    #   :time_created => Time.now, # used for
    #   :time_from => unix_time_soon_from, # begin of perdiod for theese values
    #   :time_to => unix_time_soon_to,
    #   :temperature => temperatures[1][0].to_f, # in Celsius
    #   :pressure => pressures[1][0].to_f, # in hPa
    #   :wind_kmh => winds[1][0].to_f, # in km/h
    #   :wind => winds[1][0].to_f / 3.6, # in m/s - preferred
    #   :snow => snows[1][0].to_f, # in mm
    #   :rain => rains[1][0].to_f, # in mm
    #   :provider => 'Onet.pl' # provider name
    # }]
  end

  private

  # Fetching and storing
  def check_online( defin )
    body = fetch( defin )
    processed = process( body )
    weathers = Weather.create_from( processed, defin )
    
    #puts weathers.inspect
    weathers.each do |w|
      w.store
    end

    return weathers
  end

  # Download website
  def fetch( defin )
    body = Net::HTTP.get( URI.parse( defin[:url] ) )
    f = File.new('delme.txt','w')
    f.puts body
    f.close
    return body
  end

  # DEPRECATED
  def DEP_store( data, defin )
    #f = File.new( File.join("data", "weather", self.class.to_s+".txt"), "a")
    f = File.new( File.join( WeatherRipper::WEATHER_DIR, self.class.to_s+".txt"), "a")

    data.each do |d|
      f.puts("#{d[:time_created].to_i}; '#{defin[:city].to_s}'; #{d[:provider].to_s}; #{defin[:coord][:lat]}; #{defin[:coord][:lon]};   #{d[:time_from].to_i}; #{d[:time_to].to_i}; #{d[:temperature]}; #{d[:wind]}; #{d[:pressure]}; #{d[:rain]}; #{d[:snow]}")
      DbStore.instance.store_weather_data( d, defin )

      puts "#{defin[:city].to_s}"
    end
    f.close
  end
  

end
