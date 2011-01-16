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
    if not h[:city_country].to_s == ""
      str += " (#{h[:city_country]})"
    end
    if not h[:city_metar].to_s == ""
      str += " - #{h[:city_metar]}"
    end
    str += "\n"

    str += "Time: #{h[:time].localtime.to_human}\n" unless h[:time].nil?
    str += "Time to: #{h[:time_to].localtime.to_human}\n" unless h[:time_to].nil?
    str += "Wind: #{h[:wind].to_s_round( 1 )} m/s\n" unless h[:wind].nil?
    str += "Temperature: #{h[:temperature].to_s_round( 1 )} C\n" unless h[:temperature].nil?
    str += "Pressure: #{h[:pressure]} hPa\n" unless h[:pressure].nil?
    str += "Cloudiness: #{h[:cloudiness]} %\n" unless h[:cloudiness].nil?
    str += "Rain level: #{h[:rain_metar]}\n" unless h[:rain_metar].nil?
    str += "Rain: #{h[:rain]} mm\n" unless h[:rain].nil?
    str += "Snow level: #{h[:snow_metar]}\n" unless h[:snow_metar].nil?
    str += "Snow: #{h[:snow]} mm\n" unless h[:snow].nil?
    str += "Provider: #{h[:weather_provider]}\n" unless h[:weather_provider].nil?
    str += "Future prediction\n" if true == h[:predicted]

    
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

  # Get table data of last metars
  def get_array_of_last_metar( city, last_metars )
    last_metars = last_metars.to_i
    last_metars = 10 if last_metars < 1

    data = @extractor.get_array_of_last_metar( city, last_metars )
    str = "City: #{data[:city].name} (#{data[:city].country})\n"

    data[:data].each do |d|
      str += "#{d[:time].localtime.to_human}: #{d[:temperature].to_s_round( 1 )} C, #{d[:wind].to_s_round( 1 )} m/s\n"
    end

    return str
  end

  def get_array_of_last_weather( city, last_w )
    last_w = last_w.to_i
    last_w = 4 if last_w < 1

    data = @extractor.get_array_of_last_weather( city, last_w )
    str = "City: #{data[:city].name} (#{data[:city].country})\n"

    data[:data].each do |d|
      str += "#{d[:time].localtime.to_human} - #{d[:time_to].localtime.to_time_human}#{" FP" if true == d[:predicted]} [#{d[:weather_provider].to_s}] #{d[:temperature].to_s_round( 1 )} C, #{d[:wind].to_s_round( 1 )} m/s\n"
    end

    return str
  end

end
