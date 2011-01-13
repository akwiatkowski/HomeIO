#!/usr/bin/ruby1.9.1
#encoding: utf-8

require './lib/storage/extractors/extractor_active_record.rb'

class JabberProcessor
  def self.process_command( command )

    puts command
    
    command =~ /([^;]*);([^;]*)(.*)/
    first_part = $1.to_s.downcase
    additional_param = $2
    additional_params = $3.to_s.split(/;/)
    # puts additional_params.inspect

    return case first_part
    when 'cities' then ExtractorActiveRecord.instance.str_get_cities
    when 'metar_city' then ExtractorActiveRecord.instance.str_get_last_metar( additional_param )
    when 'metar_temp' then ExtractorActiveRecord.instance.str_temperature_metar_list
    when 'metar_array' then ExtractorActiveRecord.instance.str_get_array_of_last_metar( additional_param, additional_params[1] )
    when 'weather_array' then ExtractorActiveRecord.instance.str_get_array_of_last_weather( additional_param, additional_params[1] )
    else 'Bad command'
    end

    #city_weather = last_city( command )
    #return response = city_weather.inspect
  end

end
