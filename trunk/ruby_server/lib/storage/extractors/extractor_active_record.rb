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

    str =  "City: #{m.city}\n"
    str += "Time: #{m.output[:time].localtime.to_human}\n"
    str += "Wind: #{m.output[:wind_mps].to_s_round( 1 )} m/s\n"
    str += "Temperature: #{m.output[:temperature].to_s_round( 1 )} C\n"
    str += "Pressure: #{m.output[:pressure]} hPa\n"
    str += "Cloudiness: #{m.output[:cloudiness]} %\n"
    str += "Rain level: #{m.output[:rain_metar]}\n"
    str += "Snow level: #{m.output[:snow_metar]}\n"
    str += "Specials:\n"

    # specials
    m.output[:specials].each do |s|
      spec_str = "- #{s[:intensity]} #{s[:descriptor]} #{s[:precipitation]} #{s[:obscuration]} #{s[:misc]}\n"
      str += spec_str
    end

    return str
  end

  # Summary of last metars
  def str_summary_metar_list
    str = "ID. Name (Country - METAR) - temperature\n"

    cities = get_cities
    cities.each do |c|
      wma = WeatherMetarArchive.find(:first, :conditions => {:city_id => c.id}, :order => 'time_from DESC')
      if not wma.nil?
        str += "#{c.name} (#{c.country}): #{wma.temperature} C, #{wma.wind} m/s, #{wma.pressure} hPa, #{wma.rain_metar} rain, #{wma.snow_metar} snow\n"
      end
    end

    return str
  end

  # Get table data of last metars
  def str_get_array_of_last_metar( city, last_metars )
    last_metars = last_metars.to_i
    last_metars = 10 if last_metars < 1

    c = search_city( city )
    str = "City: #{c.name} (#{c.country})\n"

    wmas = WeatherMetarArchive.find(:all, :conditions => {:city_id => c.id}, :order => 'time_from DESC', :limit => last_metars )

    wmas.reverse.each do |wma|
      m = MetarCode.process_archived(wma.raw, wma.time_from.year, wma.time_from.month)
      str += "#{m.output[:time].localtime.to_human}: #{m.output[:temperature].to_s_round( 1 )} C, #{m.output[:wind_mps].to_s_round( 1 )} m/s\n"
    end

    return str
  end

  def str_get_array_of_last_weather( city, last_w )
    last_w = last_w.to_i
    last_w = 10 if last_w < 1

    c = search_city( city )
    str = "City: #{c.name} (#{c.country})\n"

    was = WeatherArchive.find(:all, :conditions => {:city_id => c.id}, :order => 'time_from DESC', :limit => last_w )

    was.reverse.each do |wa|
      str += "#{wa.time_from.localtime.to_human} - #{wa.time_to.localtime.to_human}: #{wa.temperature.to_s_round( 1 )} C, #{wa.wind.to_s_round( 1 )} m/s\n"
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
