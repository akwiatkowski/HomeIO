require 'yaml'
require './lib/weather_ripper.rb'

# Cities

class City < ActiveRecord::Base

  validates_presence_of :country, :name, :lat, :lon

  # when we have to create another city with the same name we use suffix
  NAME_SUFFIX_WHEN_NEEDED = '#'

  # verbose mode, for development
  VERBOSE = true


  # Calculate distance for a city
  def recalculate_distance
    self.calculated_distance = Geolocation.distance( self.lat , self.lon )
  end

  before_save :recalculate_distance


  # Save method which log errors into HomeIO logs
  def safe_save
    begin
      self.save!
    rescue => e
      log_error( self, e, self.inspect )
    end
    return self
  end

  # Create cities from configuration
  def self.create_from_config_metar
    self.create_from_config_metar
    self.create_from_config_nonmetar
  end

  # Create method with checking names and distances
  def self.create_with_distance_check( h )

    puts "search #{h[:name]}" if VERBOSE
    #dbc = City.find(:first, :conditions => [
    #  "(name like '%' || ? || '%') or ( lat = ? and lon = ? )",
    #  h[:name],
    #  h[:lat],
    #  h[:lon]
    #  ])
    dbc = City.find_by_name( h[:name] )
    # TODO some problem when using mixed language names

    # if city was found
    if not dbc.nil?
      dist = Geolocation.distance_2points( dbc.lat, dbc.lon, h[:lat], h[:lon] )
      puts " found distance #{dist}"  if VERBOSE
      
      if dist < Geolocation::CITY_DISTANCE_TOLERANCE
        # this city is already stored in DB
        puts "  in tolerance"  if VERBOSE
        return dbc

      else
        # create city with sufix
        puts " outside tolerance"  if VERBOSE
        h[:name] += NAME_SUFFIX_WHEN_NEEDED
        return City.new( h ).safe_save

      end
    else
      # not found - create city
      return City.new( h ).safe_save
    end
  end

  private

  # Create cities from configuration
  def self.create_from_config_metar
    cities = ConfigLoader.instance.config( MetarConstants::CONFIG_TYPE )[:cities]
    cities.each do |c|
      City.new({
          :id => c[:id], # force id
          :name => c[:name],
          :country => c[:country],
          :metar => c[:metar],
          :lat => c[:coord][:lat],
          :lon => c[:coord][:lon],
        }).safe_save
    end
  end

  # Create cities from configuration (non metar cities)
  def self.create_from_config_nonmetar
    providers = WeatherRipper.instance.providers
    providers.each do |p|
      # iteration for every city in current provider
      # checking if this city is in table cities
      puts "#{p.class} - #{p.config[:defs].size}"

      p.config[:defs].each do |pc|
        self.create_with_distance_check(
          {
            :name => pc[:city], #:name => pc[:name],
            :country => pc[:country],
            :lat => pc[:coord][:lat],
            :lon => pc[:coord][:lon],
          }
        )
      end

    end
  end



end
