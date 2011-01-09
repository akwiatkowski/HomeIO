require 'singleton'
require './lib/storage/storage.rb'
require './lib/metar/metar_code.rb'

# Retrieve data from DB

class ExtractorActiveRecord
  include Singleton

  def initialize
    StorageActiveRecord.instance
  end

  # Get all cities
  def get_cities
    return City.find(:all, :conditions => {}, :order => 'calculated_distance DESC')
  end
  
  # Get all cities (for jabber communication)
  def str_get_cities
    cities = get_cities
    cities_txt = cities.collect{|c| "#{c.id}. #{c.name} (#{c.country} - #{c.metar}) - #{c.calculated_distance.round}"}.join("\n")
    cities_header = "ID. Name (Country - METAR) - distance [km]\n"
    return cities_header + cities_txt
  end

  # Search city using id, name, metar, partial of name
  def search_city( city )
    c = City.find_by_id( city )
    c = City.find_by_name( city ) if c.nil?
    c = City.find_by_metar( city ) if c.nil?
    c = City.find(:first, :conditions => ["name like '%' || ? || '%' ", city]) if c.nil?
    return c
  end

  def get_last_metar( city )
    c = search_city( city )
    return :city_not_found if c.nil?

    wma = WeatherMetarArchive.find(:first, :conditions => {:city_id => c.id}, :order => 'time_from DESC')
    return MetarCode.process_archived(wma.raw, wma.time_from.year, wma.time_from.month)
  end

  def str_get_last_metar( city )
    m = get_last_metar( city )
    return m unless m.kind_of?(MetarCode) # return error message

    str = ""
    str += "Time: #{m.output[:time].to_human}\n"
    str += "Wind: #{m.output[:wind_mps]} m/s\n"
    str += "Temperature: #{m.output[:temperature]} C\n"
    str += "Pressure: #{m.output[:pressure]} hPa\n"
    str += "Cloudiness #{m.output[:cloudiness]} %\n"
    str += "Rain level: #{m.output[:rain_metar]}\n"
    str += "Snow level: #{m.output[:snow_metar]}\n"

    return str
  end

  def str_temperature_metar_list
    str = "ID. Name (Country - METAR) - temperature\n"

    cities = get_cities
    cities.each do |c|
      wma = WeatherMetarArchive.find(:first, :conditions => {:city_id => c.id}, :order => 'time_from DESC')
      if not wma.nil?
        str += "#{c.id}. #{c.name} (#{c.country} - #{c.metar}) - #{wma.temperature} C\n"
      end
    end

    return str
  end




  def last_city( city )
    begin
      city = City.find_by_name( city )
      metar = WeatherMetarArchive.find(:last, :conditions => {:city_id => city.id})
      # TODO many providers
      weather = WeatherArchive.find(:last, :conditions => {:city_id => city.id})
      return {:metar => metar, :weather => weather}
    rescue
      return {:status => :not_found}
    end
  end

end
