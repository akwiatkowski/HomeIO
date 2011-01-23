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
    #return City.find(:all, :conditions => {}, :order => 'calculated_distance DESC')
    return City.find(:all, :conditions => {}, :order => 'calculated_distance DESC')
  end
  
  # Search city using id, name, metar, partial of name
  def search_city( city )
    c = City.find_by_id( city )
    c = City.find_by_name( city ) if c.nil?
    c = City.find_by_metar( city ) if c.nil?
    #c = City.find(:first, :conditions => ["name like ?", "%#{city}%"]) if c.nil?
    c = City.find(:first, :conditions => ["lower(name) like lower(?)", "%#{city}%"]) if c.nil?
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
    return nil if wma.nil?
    return MetarCode.process_archived(wma.raw, wma.time_from.year, wma.time_from.month)
  end

  # Convert MetarCode to hash
  def metarcode_to_hash( m )
    return nil if m.nil?

    return {
      :city => m.city_hash[:name],
      :city_country => m.city_hash[:country],
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
    return nil if wma.nil?

    c = City.find( wma.city_id )
    return {
      :city => c.name,
      :city_country => c.country,
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

  # Get array of last metars
  def get_array_of_last_metar( city, last_metars )
    a = Array.new
    c = search_city( city )
    wmas = WeatherMetarArchive.find(:all, :conditions => {:city_id => c.id}, :order => 'time_from DESC', :limit => last_metars )
    wmas.reverse.each do |wma|
      a << wma_with_metarcode_to_hash( wma )
    end
    return {:data => a, :city => c}
  end

  # Convert WeatherArchive to hash
  def wa_to_hash( wa )
    c = City.find( wa.city_id )
    if not wa.weather_provider_id.nil?
      wp = wa.weather_provider.name
    else
      wp = 'N/A'
    end
    
    return {
      :city => c.name,
      :city_country => c.country,
      :time => wa.time_from,
      :time_to => wa.time_to,
      :temperature => wa.temperature,
      :wind => wa.wind,
      :pressure => wa.pressure,
      :rain => wa.rain,
      :snow => wa.snow,
      :weather_provider => wp,
      # was this predicted or measured by provider
      :predicted => wa.predicted?
    }
  end

  # Get table data of last weathers
  def get_array_of_last_weather( city, last_metars )
    a = Array.new
    c = search_city( city )
    was = WeatherArchive.find(:all, :conditions => {:city_id => c.id}, :order => 'time_from DESC', :limit => last_metars, :include => :weather_provider )
    was.reverse.each do |wa|
      a << wa_to_hash( wa )
    end
    return {:data => a, :city => c}
  end

  # Search nearest WeatherMetarArchive
  def search_wma( city, time )
    c = search_city( city )
    return nil if c.nil?
    return _search_archived_data( WeatherMetarArchive, 'city_id', c.id, 2*24*3600, time )
  end

  # Search nearest WeatherArchive
  def search_wa( city, time )
    c = search_city( city )
    return nil if c.nil?
    return _search_archived_data( WeatherArchive, 'city_id', c.id, 2*24*3600, time )
  end

  # Search nearest metar, return hash
  def search_metar( city, time )
    wma = search_wma( city, time )
    return nil if wma.nil?
    return wma_with_metarcode_to_hash( wma )
  end

  # Search nearest weather, return hash
  def search_weather( city, time )
    wa = search_wa( city, time )
    return nil if wa.nil?
    return wa_to_hash( wa )
  end

  # Search metar or weather
  def search_metar_or_weather( city, time )
    hm = search_metar( city, time )
    return hm unless hm.nil?

    hw = search_weather( city, time )
    return hw
  end

  # Basic city information
  def city_basic_info( city )
    c = search_city( city )
    return nil if c.nil?

    metar_count = WeatherMetarArchive.count(:all, :conditions => {:city_id => c.id})
    weather_count = WeatherArchive.count(:all, :conditions => {:city_id => c.id})

    first_metar = WeatherMetarArchive.find(:first, :conditions => {:city_id => c.id}, :order => 'time_from ASC')
    last_metar = WeatherMetarArchive.find(:last, :conditions => {:city_id => c.id}, :order => 'time_from ASC')

    first_weather = WeatherArchive.find(:first, :conditions => {:city_id => c.id}, :order => 'time_from ASC')
    last_weather = WeatherArchive.find(:last, :conditions => {:city_id => c.id}, :order => 'time_from ASC')

    return {
      :city_obj => c,
      :city => c.name,
      :city_country => c.country,
      :city_metar => c.metar,
      :metar_count => metar_count,
      :weather_count => weather_count,
      :first_metar => first_metar,
      :last_metar => last_metar,
      :first_weather => first_weather,
      :last_weather => last_weather
    }
  end

  # Advanced city information
  def city_adv_info( city )
    data = city_basic_info( city )
    return nil if data.nil?

    c = data[:city_obj]

    data[:high_temp_metar] = WeatherMetarArchive.find(:first, :conditions => {:city_id => c.id}, :order => 'temperature DESC')
    puts "City Adv Info :high_temp_metar #{Time.now}"
    data[:low_temp_metar] = WeatherMetarArchive.find(:first, :conditions => {:city_id => c.id}, :order => 'temperature ASC')
    puts "City Adv Info :low_temp_metar #{Time.now}"
    data[:high_temp_weather] = WeatherArchive.find(:first, :conditions => {:city_id => c.id}, :order => 'temperature DESC')
    puts "City Adv Info :high_temp_weather #{Time.now}"
    data[:low_temp_weather] = WeatherArchive.find(:first, :conditions => {:city_id => c.id}, :order => 'temperature ASC')
    puts "City Adv Info :low_temp_weather #{Time.now}"

    data[:high_wind_metar] = WeatherMetarArchive.find(:first, :conditions => {:city_id => c.id}, :order => 'wind DESC')
    puts "City Adv Info :high_wind_metar #{Time.now}"
    data[:low_wind_metar] = WeatherMetarArchive.find(:first, :conditions => {:city_id => c.id}, :order => 'wind ASC')
    puts "City Adv Info :low_wind_metar #{Time.now}"
    data[:high_wind_weather] = WeatherArchive.find(:first, :conditions => {:city_id => c.id}, :order => 'wind DESC')
    puts "City Adv Info :high_wind_weather #{Time.now}"
    data[:low_wind_weather] = WeatherArchive.find(:first, :conditions => {:city_id => c.id}, :order => 'wind ASC')
    puts "City Adv Info :low_wind_weather #{Time.now}"

    return data
  end
  

  private

  # Universal searcher, get closest object to *time* checking within *time_range*
  # seconds
  # 
  # DB table need to has column 'time_from'
  #
  # *klass* - AR class
  # *key_name* - foreign key column name used for searching
  # *key_value* - foreign key value
  # *time_range* - second range for searching, default = 24*3600
  # *time* - Time for searching 'when'
  def _search_archived_data( klass, key_name, key_value, time_range, time )
    conds = [
      "#{key_name} = ? and time_from between ? and ?",
      key_value,
      time - time_range,
      time + 1
    ]
    #puts conds.inspect
    obj_before = klass.find(:first,
      :conditions => conds,
      :order => 'time_from DESC')

    conds = [
      "#{key_name} = ? and time_from between ? and ?",
      key_value,
      time - 1,
      time + time_range
    ]
    #puts conds.inspect
    obj_after = klass.find(:first,
      :conditions => conds,
      :order => 'time_from ASC')

    #puts wma_before.inspect, wma_after.inspect

    # nothing found
    if obj_before.nil? and obj_after.nil?
      return nil
    elsif obj_before.nil?
      return obj_after
    elsif obj_after.nil?
      return obj_before
    else

      time_before_diff = (obj_before.time_from - time).abs
      time_after_diff = (obj_after.time_from - time).abs

      if time_before_diff > time_after_diff
        return obj_after
      else
        return obj_before
      end
    end
  end


end
