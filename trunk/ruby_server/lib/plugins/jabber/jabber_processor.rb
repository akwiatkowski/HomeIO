#!/usr/bin/ruby1.9.1
#encoding: utf-8

require './lib/storage/extractors/extractor_active_record.rb'

class JabberProcessor
  def self.process_command( command )

    puts command
    
    command =~ /([^;]*);([^;]*).*/
    first_part = $1.to_s.downcase
    additional_param = $2

    return case first_part
    when 'cities' then ExtractorActiveRecord.instance.str_get_cities
    when 'metar_city' then ExtractorActiveRecord.instance.str_get_last_metar( additional_param )
    else 'Bad command'
    end

    #city_weather = last_city( command )
    #return response = city_weather.inspect
  end

end
