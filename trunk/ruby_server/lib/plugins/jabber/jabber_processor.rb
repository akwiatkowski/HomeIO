#!/usr/bin/ruby1.9.1
#encoding: utf-8

require './lib/storage/extractors/extractor_active_record.rb'
require './lib/plugins/jabber/text_interface_processor.rb'

class JabberProcessor
  def self.process_command( command )

    puts command

    params = command.to_s.split(/ /)
    puts params.inspect

    return case params[0]
    when 'help' then self.commands_help
    when '?' then self.commands_help
    when 'cities' then TextInterfaceProcessor.instance.get_cities
      # get last metar
    when 'metar_city' then TextInterfaceProcessor.instance.get_last_metar( params[1] )
      # summary of last metars
    when 'metar_summary' then TextInterfaceProcessor.instance.summary_metar_list
    when 'metar_array' then TextInterfaceProcessor.instance.get_array_of_last_metar( params[1], params[2] )
    when 'weather_array' then TextInterfaceProcessor.instance.get_array_of_last_weather( params[1], params[2] )
      # TODO implement
    when 'metar_search' then ExtractorActiveRecord.instance.str_search_metar( params )
      # TODO
    when 'count' then nil
    else 'Bad command'
    end

    #city_weather = last_city( command )
    #return response = city_weather.inspect
  end

  private

  # Help for jabber commands
  def self.commands_help
    str = ""
    str += "'help', '?' - this help :]\n"
    str += "'cities' - list of all cities\n"
    str += "'metar_city <metar code or id>' - last metar data for city\n"
    str += "'metar_summary' - metar summary of all cities\n"
    str += "'metar_array <metar code or id> <count>' - get <count> last metars for city\n"
    str += "'metar_search <metar code> <time ex. 2010-01-01 12:00' - coming soon, search for metar data for city at specified time\n"
    str += ""
    str += ""
    str += ""
    str += ""

    return str
  end

end
