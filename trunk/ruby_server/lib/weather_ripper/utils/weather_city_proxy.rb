require 'singleton'
require './lib/metar_logger.rb'

# Generate dynamic IDs and fix city names

class WeatherCityProxy
  include Singleton

  # Last free id for city
  attr_reader :last_city_id

  # Verbose mode
  attr_accessor :verbose
  # Log warning when city with other name is near another city
  # And they are joined
  attr_accessor :log_different_city_names

  # when we have to create another city with the same name we use suffix
  NAME_SUFFIX_WHEN_NEEDED = '#'

  # location within this distance is threated like the same city [km]
  CITY_DISTANCE_TOLERANCE = 15

  def initialize
    @last_city_id = 1
    @verbose = true
    @log_different_city_names = true
  end

  # Fetch and process when needed
  # Deadlock fix
  def post_init
    attach_metar if @metar_cities.nil?
    attach_weather if @weather_cities.nil?
  end

  # Return unified cities array
  def cities_array
    post_init

    a = Array.new
    @metar_cities.each do |m|
      a << {
        :id => m[:id],
        :country => m[:country],
        :name => m[:name],
        :lat => m[:coord][:lat],
        :lon => m[:coord][:lon]
      }
    end

    @weather_cities.keys.each do |k|
      @weather_cities[ k ].each do |c|
        a << {
          :id => c[:id],
          :country => c[:country],
          :name => c[:city],
          :lat => c[:coord][:lat],
          :lon => c[:coord][:lon]
        }
      end
    end

    return a.uniq.sort{|a,b| a[:id] <=> b[:id] }
  end

  private

  def fix_weather_cities_definition( k )
    # search for city with similar name or nearly distance
    @weather_cities[ k ].each do |c|
      fix_weather_city( c )
    end
  end

  def fix_weather_city( c )
    # checking on metars
    @metar_cities.each do |mc|
      # matching names or distance
      dist = Geolocation.distance_2points( c[:coord][:lat], c[:coord][:lon], mc[:coord][:lat], mc[:coord][:lon] )
      if ( mc[:name] == c[:city] ) or ( dist < CITY_DISTANCE_TOLERANCE and not c[:near_other_city] == true )
        # city exist
        if not mc[:name] == c[:city] and @log_different_city_names
          AdvLog.instance.logger( self ).warning("Cities merged #{mc[:name]} has #{c[:city]}")
        end

        c[:id] = mc[:id]
        id_was_used( mc[:id] )
        puts "reusing id from metar #{mc[:id]}, #{mc[:name]} == #{c[:city]}" if @verbose
        return c
      end
    end

    # checking on weather's providers
    @weather_cities.keys.each do |key|
      wp = @weather_cities[ key ]
      # checking on weather's cities
      wp.each do |wc|
        # *wc* need to has id already
        if not wc[:id].nil?

          # matching names or distance
          dist = Geolocation.distance_2points( c[:coord][:lat], c[:coord][:lon], wc[:coord][:lat], wc[:coord][:lon] )
          if ( ( wc[:city] == c[:city] ) or ( dist < CITY_DISTANCE_TOLERANCE ) )
            # city exist
            if not wc[:city] == c[:city] and @log_different_city_names
              AdvLog.instance.logger( self ).warning("Cities merged #{wc[:name]} has #{c[:city]}")
            end

            c[:id] = wc[:id]
            id_was_used( wc[:id] )
            puts "reusing id from weather #{wc[:id]}, #{wc[:city]} == #{c[:city]}" if @verbose
            return
          end

        end
      end
    end

    # city without id - using a new one
    c[:id] = @last_city_id
    id_was_used( @last_city_id )
    puts "new id #{c[:id]}, #{c[:city]}"  if @verbose
    return c
  end

  # Attach to METAR configuration
  def attach_metar
    # metars has predefined id
    @metar_cities = MetarLogger.instance.cities

    # *@last_city_id* updating
    @metar_cities.each do |c|
      id_was_used( c[:id] )
    end
  end

  # Attach to nonmetar, weather ripper, configuration
  def attach_weather
    @weather_cities = Hash.new
    
    WeatherRipper.instance.providers.each do |obj|
      k = obj.class.to_s.to_sym
      @weather_cities[ k ] = obj.defs
      fix_weather_cities_definition( k )
    end
  end


  # Usable ID will be larger than any ID uses so far
  def id_was_used( id )
    if @last_city_id <= id
      @last_city_id = id + 1
    end
  end

end
