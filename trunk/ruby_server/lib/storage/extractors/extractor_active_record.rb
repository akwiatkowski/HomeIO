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

  # Convert MetarCode to string
  # TODO: refactor
  def str_metar_to_s( m )
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

  def str_get_last_metar( city )
    m = get_last_metar( city )
    return m unless m.kind_of?(MetarCode) # return error message
    return str_metar_to_s( m )
  end

  # Summary of last metars
  def str_summary_metar_list
    str = "ID. Name (Country - METAR) - temperature\n"

    cities = get_cities
    cities.each do |c|
      # puts c.inspect
      #count = WeatherMetarArchive.count(:conditions => {:city_id => c.id})
      #if count > 0
      wma = WeatherMetarArchive.find(:first, :conditions => [
          "city_id = ? and time_from >= ?",
          c.id,
          Time.now - 6*3600
        ],
        :order => 'time_from DESC')
      if not wma.nil?
        str += "#{c.name} (#{c.country}): #{wma.temperature} C, #{wma.wind} m/s, #{wma.pressure} hPa, #{wma.rain_metar} rain, #{wma.snow_metar} snow\n"
      end
      #end
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

  # Search nearest metar
  def search_metar( city, time )
    c = search_city( city )
    return nil if c.nil?

    conds = [
      "city_id = ? and time_from between ? and ?",
      c.id,
      time - 24*3600,
      time + 1
    ]
    #puts conds.inspect
    wma_before = WeatherMetarArchive.find(:first,
      :conditions => conds,
      :order => 'time_from DESC')

    conds = [
      "city_id = ? and time_from between ? and ?",
      c.id,
      time - 1,
      time + 24*3600
    ]
    #puts conds.inspect
    wma_after = WeatherMetarArchive.find(:first,
      :conditions => conds,
      :order => 'time_from ASC')

    #puts wma_before.inspect, wma_after.inspect

    # nothing found
    if wma_before.nil? and wma_after.nil?
      return nil
    elsif wma_before.nil?
      return wma_after
    elsif wma_after.nil?
      return wma_before
    else

      time_before_diff = (wma_before.time_from - time).abs
      time_after_diff = (wma_after.time_from - time).abs

      if time_before_diff > time_after_diff
        return wma_after
      else
        return wma_before
      end

    end


  end

  # Search metar archive
  def str_search_metar( params )
    params[2] =~ /(\d{4})-(\d{1,2})-(\d{1,2})/
    y = $1.to_i
    m = $2.to_i
    d = $3.to_i

    params[3] =~ /(\d{1,2}):(\d{1,2})/
    h = $1.to_i
    min = $2.to_i

    t = Time.mktime(y, m, d, h, min, 0, 0)

    wma = search_metar( params[1], t )
    return "Not found" if wma.nil?
    m = MetarCode.process_archived(wma.raw, wma.time_from.year, wma.time_from.month)
    return str_metar_to_s( m )
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
