#!/usr/bin/ruby1.9.1
#encoding: utf-8

require './lib/storage/extractors/extractor_active_record.rb'
require './lib/plugins/jabber/text_interface_processor.rb'
require './lib/utils/adv_log.rb'

class JabberProcessor
  def self.process_command( command, from = 'N/A' )

    AdvLog.instance.logger( self ).info("C. from #{from}: #{command.inspect}")
    puts command
    t = Time.now

    params = command.to_s.split(/ /)
    puts params.inspect

    output = case params[0]
    when 'help', '?' then self.commands_help
    when 'c' then TextInterfaceProcessor.instance.get_cities
      # get last metar
    when 'wmc' then TextInterfaceProcessor.instance.get_last_metar( params[1] )
      # summary of last metars
    when 'wms' then TextInterfaceProcessor.instance.summary_metar_list
      # some last metars
    when 'wma' then TextInterfaceProcessor.instance.get_array_of_last_metar( params[1], params[2] )
      # some last weathers
    when 'wra' then TextInterfaceProcessor.instance.get_array_of_last_weather( params[1], params[2] )
      # search metar at
    when 'wmsr' then TextInterfaceProcessor.instance.search_metar( params )
      # search weather (non-metar) at
    when 'wmsr' then TextInterfaceProcessor.instance.search_weather( params )
      # search weather at
    when 'wsr' then TextInterfaceProcessor.instance.search_metar_or_weather( params )
      # city information
    when 'ci' then TextInterfaceProcessor.instance.city_basic_info( params[1] )
      # advanced city info and stats
    when 'cii' then TextInterfaceProcessor.instance.city_adv_info( params[1] )
    else 'Wrong command'
    end

    AdvLog.instance.logger( self ).info("C. from #{from}: time #{Time.now - t}")
    
    return output
  end

  private

  # Help for jabber commands
  def self.commands_help
    str = ""
    str += "'help', '?' - this help :]\n"
    str += "'c' - list of all cities\n"
    str += "'ci <id, metar code, name or name fragment>' - city logged data basic statistics\n"
    str += "'wmc <id, metar code, name or name fragment>' - last metar data for city\n"
    str += "'wms' - metar summary of all cities\n"
    str += "'wma <id, metar code, name or name fragment> <count>' - get <count> last metars for city\n"
    str += "'wra <id, metar code, name or name fragment> <count>' - get <count> last weather (non-metar) data for city\n"
    str += "'wmsr <id, metar code, name or name fragment> <time ex. 2010-01-01 12:00' - search for metar data for city at specified time\n"
    str += "'wrsr <id, metar code, name or name fragment> <time ex. 2010-01-01 12:00' - search for weather (non-metar) data for city at specified time\n"
    str += "'wsr <id, metar code, name or name fragment> <time ex. 2010-01-01 12:00' - search for weather (metar or non-metar) data for city at specified time\n"
    str += ""
    str += ""
    str += ""

    return str
  end

end
