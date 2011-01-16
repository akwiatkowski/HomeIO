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
  
  # Search city using id, name, metar, partial of name
  def search_city( city )
    c = City.find_by_id( city )
    c = City.find_by_name( city ) if c.nil?
    c = City.find_by_metar( city ) if c.nil?
    c = City.find(:first, :conditions => ["name like '%' || ? || '%' ", city]) if c.nil?
    return c
  end

  # Get last metar for city
  def get_last_metar( city )
    c = search_city( city )
    return nil if c.nil?

    wma = WeatherMetarArchive.find(:first, :conditions => {:city_id => c.id}, :order => 'time_from DESC')
    return wma_with_metarcode_to_hash( wma )
  end

  # Convert WeatherMetarArchive to MetarCode
  # Warning: WMA need to has correct metar (.raw)
  def wma_to_metarcode( wma )
    return MetarCode.process_archived(wma.raw, wma.time_from.year, wma.time_from.month)
  end

  # Convert MetarCode to hash
  def metarcode_to_hash( m )
    return {
      :city => m.city_hash[:name],
      :city_metar => m.city,
      :time => m.output[:time].localtime,
      :wind => m.output[:wind_mps],
      :temperature => m.output[:temperature],
      :pressure => m.output[:pressure],
      :cloudiness => m.output[:cloudiness],
      :rain_metar => m.output[:rain_metar],
      :snow_metar => m.output[:snow_metar],
      :specials => m.output[:specials]
    }
  end

  # Convert WeatherMetarArchive to hash
  # Useful when WMA is without metar (.raw)
  def wma_to_hash( wma )
    c = City.find( wma.city_id )
    return {
      :city => c.name,
      :city_metar => c.metar,
      :time => wma.time_from,
      :wind => wma.wind,
      :temperature => wma.temperature,
      :pressure => wma.pressure,
      :rain_metar => wma.rain_metar,
      :snow_metar => wma.snow_metar
    }
  end

  # Try to use MetarCode, if not possible use direct conversion to hash
  def wma_with_metarcode_to_hash( wma )
    hash = wma_to_hash( wma )
    begin
      m = wma_to_metarcode( wma )
      new_hash = metarcode_to_hash( m )
      # if MetarCode is valid it can be used then
      hash = new_hash if m.valid?
    rescue
    end
    return hash
  end

  # Last metar summary
  def summary_metar_list
    array = Array.new
    
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
        array << {
          :city => c.name,
          :city_country => c.country,
          :temperature => wma.temperature,
          :wind => wma.wind,
          :pressure => wma.pressure
        }
      end
    end
    
    return array
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
