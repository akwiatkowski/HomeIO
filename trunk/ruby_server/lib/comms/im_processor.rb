#!/usr/bin/ruby
#encoding: utf-8

# This file is part of HomeIO.
#
#    HomeIO is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    HomeIO is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.


require 'singleton'
#require './lib/storage/extractors/extractor_active_record.rb'
require './lib/comms/direct_extractor.rb'
# not ready, and I don't know if it will be used
#require './lib/comms/tcp_client_extractor.rb'

# Process commands and output for text interface like jabber, gg

class ImProcessor
  include Singleton
  
  def initialize
    @extractor = DirectExtractor.instance
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

  # Convert weather data, only city data, to string
  def hash_city_to_s( h )
    str = ""
    str += "City: #{h[:city]}"
    if not h[:city_country].to_s == ""
      str += " (#{h[:city_country]})"
    end
    if not h[:city_metar].to_s == ""
      str += " - #{h[:city_metar]}"
    end
    return str
  end

  # Convert weather data in hash to string
  def hash_to_s( h )
    str = ""

    str += hash_city_to_s( h )
    str += "\n"

    str += "Time: #{h[:time].localtime.to_human}\n" unless h[:time].nil?
    str += "Time to: #{h[:time_to].localtime.to_human}\n" unless h[:time_to].nil?
    str += "Temperature: #{h[:temperature].to_s_round( 1 )} C\n" unless h[:temperature].nil?
    str += "Wind: #{h[:wind].to_s_round( 1 )} m/s\n" unless h[:wind].nil?
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
      str += "#{d[:time].localtime.to_human} - #{d[:time_to].localtime.to_time_human}#{" FP" if true == d[:predicted]} [#{d[:weather_provider].to_s}] #{d[:temperature].to_s_round( 1 )} C, #{d[:wind].to_s_round( 1 )} m/s, #{d[:rain].to_s_round( 1 )} mm rain, #{d[:snow].to_s_round( 1 )} mm snow\n"
    end

    return str
  end

  # Search metar archive
  def search_metar( params )
    t = create_time_from_string( params[2], params[3] )
    h = @extractor.search_metar( params[1], t )
    return "Not found" if h.nil?
    return hash_to_s( h )
  end

  # Search metar archive
  def search_weather( params )
    t = create_time_from_string( params[2], params[3] )
    h = @extractor.search_weather( params[1], t )
    return "Not found" if h.nil?
    return hash_to_s( h )
  end

  # Search metar archive
  def search_metar_or_weather( params )
    t = create_time_from_string( params[2], params[3] )
    h = @extractor.search_metar_or_weather( params[1], t )
    return "Not found" if h.nil?
    return hash_to_s( h )
  end

  # Show simplified WeatherMetarArchive
  def wma_to_simple_s( wma )
    str = ""
    str += "Time: #{wma.time_from.localtime.to_human}\n"
    str += "Temperature: #{wma.temperature.to_s_round( 1 )} C\n" unless wma.temperature.nil?
    str += "Wind: #{wma.wind.to_s_round( 1 )} m/s\n" unless wma.wind.nil?
    #str += "Pressure: #{h[:pressure]} hPa\n"
    #str += "Cloudiness: #{h[:cloudiness]} %\n"
    #str += "Rain level: #{h[:rain_metar]}\n"
    #str += "Snow level: #{h[:snow_metar]}\n"
    return str
  end

  # Show simplified WeatherArchive
  def wa_to_simple_s( wa )
    str = ""
    str += "Time: #{wa.time_from.localtime.to_human}\n"
    str += "Temperature: #{wa.temperature.to_s_round( 1 )} C\n" unless wa.temperature.nil?
    str += "Wind: #{wa.wind.to_s_round( 1 )} m/s\n" unless wa.wind.nil?
    #str += "Pressure: #{h[:pressure]} hPa\n" unless h[:pressure].nil?
    #str += "Cloudiness: #{h[:cloudiness]} %\n" unless h[:cloudiness].nil?
    str += "Provider: #{wa.weather_provider.name}\n" unless wa.weather_provider_id.nil?
    str += "Future prediction\n" if true == wa.predicted?
    return str
  end

  # City information and statistics
  def hash_city_info_to_s( h )
    str = ""
    str += hash_city_to_s( h )

    str += " \n"
    str += "Metar count: #{h[:metar_count]} \n"
    str += "Weather count: #{h[:weather_count]} \n \n"

    str += "First metar at: #{h[:first_metar].time_from.localtime.to_human}\n" unless h[:first_metar].nil?
    str += "Last metar at: #{h[:last_metar].time_from.localtime.to_human}\n" unless h[:last_metar].nil?
    str += "First weather at: #{h[:first_weather].time_from.localtime.to_human}\n" unless h[:first_weather].nil?
    str += "Last weather at: #{h[:last_weather].time_from.localtime.to_human}\n" unless h[:last_weather].nil?

    # show only when data available
    if not h[:high_temp_metar].nil? or h[:low_temp_metar].nil? or h[:high_wind_metar].nil? or h[:low_wind_metar].nil?
      str += " \nMETAR\n"
      str += " \nHighest temperature\n#{wma_to_simple_s(h[:high_temp_metar])}\n\n" unless h[:high_temp_metar].nil?
      str += " \nLowest temperature\n#{wma_to_simple_s(h[:low_temp_metar])}\n\n" unless h[:low_temp_metar].nil?
      str += " \nHighest wind\n#{wma_to_simple_s(h[:high_wind_metar])}\n\n" unless h[:high_wind_metar].nil?
      str += " \nLowest wind\n#{wma_to_simple_s(h[:low_wind_metar])}\n\n" unless h[:low_wind_metar].nil?
    end

    # show only when data available
    if not h[:high_temp_weather].nil? or h[:low_temp_weather].nil? or h[:high_wind_weather].nil? or h[:low_wind_weather].nil?
      str += " \nWeather\n"
      str += " \nHighest temperature\n#{wa_to_simple_s(h[:high_temp_weather])}\n\n" unless h[:high_temp_weather].nil?
      str += " \nLowest temperature\n#{wa_to_simple_s(h[:low_temp_weather])}\n\n" unless h[:low_temp_weather].nil?
      str += " \nHighest wind\n#{wa_to_simple_s(h[:high_wind_weather])}\n\n" unless h[:high_wind_weather].nil?
      str += " \nLowest wind\n#{wa_to_simple_s(h[:low_wind_weather])}\n\n" unless h[:low_wind_weather].nil?
    end

    return str
  end

  # Basic information about city logged data
  def city_basic_info( city )
    h = @extractor.city_basic_info( city )
    return "Not found" if h.nil?
    return hash_city_info_to_s( h )
  end

  def city_adv_info( city )
    h = @extractor.city_adv_info( city )
    return "Not found" if h.nil?
    return hash_city_info_to_s( h )
  end

  private

  # Create Time from YYYY-MM-DD HH:mm string format
  def create_time_from_string( date, time )
    date =~ /(\d{4})-(\d{1,2})-(\d{1,2})/
    y = $1.to_i
    m = $2.to_i
    d = $3.to_i

    time =~ /(\d{1,2}):(\d{1,2})/
    h = $1.to_i
    min = $2.to_i

    return Time.mktime(y, m, d, h, min, 0, 0)
  end

end
