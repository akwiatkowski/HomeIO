require 'singleton'
require './lib/storage/extractors/extractor_active_record.rb'

# Process commands and output for text interface like jabber

class TextInterfaceProcessor
  include Singleton
  
  def initialize
    @extractor = ExtractorActiveRecord.instance
  end

  # Get all cities
  def get_cities
    cities = @extractor.get_cities
    cities_txt = cities.collect{|c|
      if c.metar.to_s == ''
        "#{c.id}. #{c.name} (#{c.country}) - #{c.calculated_distance.round}"
      else
        "#{c.id}. #{c.name} - #{c.metar} (#{c.country}) - #{c.calculated_distance.round}"
      end
    }.join("\n")
    cities_header = "ID. Name (Country) - distance [km]\n"
    return cities_header + cities_txt
  end

  # Convert weather data in hash to string
  def hash_to_s( h )
    str = ""

    str += "City: #{h[:city]}"
    if not h[:city_metar].to_s == ""
      str += " - #{h[:city_metar]}"
    end
    str += "\n"

    str += "Time: #{h[:time].localtime.to_human}\n" unless h[:time].nil?
    str += "Wind: #{h[:wind].to_s_round( 1 )} m/s\n" unless h[:wind].nil?
    str += "Temperature: #{h[:temperature].to_s_round( 1 )} C\n" unless h[:temperature].nil?
    str += "Pressure: #{h[:pressure]} hPa\n" unless h[:pressure].nil?
    str += "Cloudiness: #{h[:cloudiness]} %\n" unless h[:cloudiness].nil?
    str += "Rain level: #{h[:rain_metar]}\n" unless h[:rain_metar].nil?
    str += "Snow level: #{h[:snow_metar]}\n" unless h[:snow_metar].nil?
    
    # metar specials
    if not h[:specials].nil? and h[:specials].size > 0
      str += "Specials:\n"
      h[:specials].each do |s|
        spec_str = "- #{s[:intensity]} #{s[:descriptor]} #{s[:precipitation]} #{s[:obscuration]} #{s[:misc]}\n"
        str += spec_str
      end
    end

    return str
  end

  # Get last metar for city
  def get_last_metar( city )
    h = @extractor.get_last_metar( city )
    return 'Not found' if h.nil?
    # return string describing metar
    return hash_to_s( h )
  end

  # Summary of last metars
  def summary_metar_list
    str = "Name (Country): temperature, wind, pressure\n"

    data = @extractor.summary_metar_list
    data.each do |d|
      str += "#{d[:city]} (#{d[:city_country]}): #{d[:temperature].to_s_round( 0 )} C, #{d[:wind].to_s_round( 1 )} m/s, #{d[:pressure]} hPa\n"
    end

    return str
  end

end
