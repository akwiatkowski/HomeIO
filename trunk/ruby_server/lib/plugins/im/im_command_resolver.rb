#!/usr/bin/ruby1.9.1
#encoding: utf-8

require './lib/storage/extractors/extractor_active_record.rb'
require './lib/plugins/im/im_processor.rb'
require './lib/utils/adv_log.rb'

class ImCommandResolver
  def self.process_command( command, from = 'N/A' )

    AdvLog.instance.logger( self ).info("C. from #{from}: #{command.inspect}")
    puts "IM command received #{command}, from #{from}"
    t = Time.now

    params = command.to_s.split(/ /)

    # compare downcase
    # some mobile phones, clients, write first letter with big letter
    output = case params[0].to_s.downcase
    when 'help', '?' then self.commands_help
    when 'c' then ImProcessor.instance.get_cities
      # get last metar
    when 'wmc' then ImProcessor.instance.get_last_metar( params[1] )
      # summary of last metars
    when 'wms' then ImProcessor.instance.summary_metar_list
      # some last metars
    when 'wma' then ImProcessor.instance.get_array_of_last_metar( params[1], params[2] )
      # some last weathers
    when 'wra' then ImProcessor.instance.get_array_of_last_weather( params[1], params[2] )
      # search metar at
    when 'wmsr' then ImProcessor.instance.search_metar( params )
      # search weather (non-metar) at
    when 'wmsr' then ImProcessor.instance.search_weather( params )
      # search weather at
    when 'wsr' then ImProcessor.instance.search_metar_or_weather( params )
      # city information
    when 'ci' then ImProcessor.instance.city_basic_info( params[1] )
      # advanced city info and stats
    when 'cix' then ImProcessor.instance.city_adv_info( params[1] )
    else "Wrong command, try 'help'"
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
    #str += ""
    #str += ""
    #str += ""

    return str
  end

end
