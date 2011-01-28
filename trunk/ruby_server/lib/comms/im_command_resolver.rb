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
require './lib/comms/im_processor.rb'
require './lib/utils/adv_log.rb'
# 
require './lib/supervisor/supervisor.rb'

# Direct command resolver
# If bots should be directly connected and run direct commands

class ImCommandResolver
  include Singleton

  def initialize
    # list of commands
    @commands = commands
  end

  def process_command( command, from = 'N/A' )

    AdvLog.instance.logger( self ).info("C. from #{from}: #{command.inspect}")
    puts "IM command received #{command}, from #{from}"
    t = Time.now
    output = nil

    params = command.to_s.split(/ /)

    # find command
    # command can has aliases
    command = @commands.select{|c| (c[:command] & [ params[0].to_s.downcase ]).size > 0 }.first
    if command.nil?
      output = wrong_command
    else
      # TODO
      # call it now, it works
      output = command[:proc].call( params )

      # TODO rewrite supervisor
      #SupervisorQueue.process_server_command({
      #    :command => command[:proc]
      #  })
    end

    AdvLog.instance.logger( self ).info("C. from #{from}: time #{Time.now - t}")
    
    return output
  end

  private

  # Commands definition
  def commands
    [
      {
        :command => ['help', '?'],
        :desc => 'this help :]',
        :proc => Proc.new{ |params| commands_help },
        #:restricted => false
      },
      {
        :command => ['c'],
        :desc => 'list of all cities',
        :proc => Proc.new{ |params| ImProcessor.instance.get_cities },
        #:restricted => false
      },
      {
        :command => ['ci'],
        :desc => 'city logged data basic statistics',
        :usage_desc => '<id, metar code, name or name fragment>',
        :proc => Proc.new{ |params| ImProcessor.instance.city_basic_info( params[1] ) },
        #:restricted => false
      },
      {
        :command => ['cix'],
        :desc => 'city logged data advanced statistics',
        :usage_desc => '<id, metar code, name or name fragment>',
        :proc => Proc.new{ |params| ImProcessor.instance.city_adv_info( params[1] ) },
        #:restricted => false
      },
      {
        :command => ['wmc'],
        :desc => 'last metar data for city',
        :usage_desc => '<id, metar code, name or name fragment>',
        :proc => Proc.new{ |params| ImProcessor.instance.get_last_metar( params[1] ) },
        #:restricted => false
      },
      {
        :command => ['wms'],
        :desc => 'metar summary of all cities',
        :proc => Proc.new{ |params| ImProcessor.instance.summary_metar_list },
        #:restricted => false
      },
      {
        :command => ['wma'],
        :desc => 'get <count> last metars for city',
        :usage_desc => '<id, metar code, name or name fragment> <count>',
        :proc => Proc.new{ |params| ImProcessor.instance.get_array_of_last_metar( params[1], params[2] ) },
        #:restricted => false
      },
      {
        :command => ['wra'],
        :desc => 'get <count> last weather (non-metar) data for city',
        :usage_desc => '<id, metar code, name or name fragment> <count>',
        :proc => Proc.new{ |params| ImProcessor.instance.get_array_of_last_weather( params[1], params[2] ) },
        #:restricted => false
      },
      {
        :command => ['wmsr'],
        :desc => 'search for metar data for city at specified time',
        :usage_desc => '<id, metar code, name or name fragment> <time ex. 2010-01-01 12:00>',
        :proc => Proc.new{ |params| ImProcessor.instance.search_metar( params ) },
        #:restricted => false
      },
      {
        :command => ['wrsr'],
        :desc => 'search for weather (non-metar) data for city at specified time',
        :usage_desc => '<id, metar code, name or name fragment> <time ex. 2010-01-01 12:00>',
        :proc => Proc.new{ |params| ImProcessor.instance.search_weather( params ) },
        #:restricted => false
      },
      {
        :command => ['wsr'],
        :desc => 'search for weather (metar or non-metar) data for city at specified time',
        :usage_desc => '<id, metar code, name or name fragment> <time ex. 2010-01-01 12:00>',
        :proc => Proc.new{ |params| ImProcessor.instance.search_metar_or_weather( params ) },
        #:restricted => false
      },
      {
        :command => ['cps'],
        :desc => 'calculate city periodical stats (metar or non-metar) at specified time interval',
        :usage_desc => '<id, metar code, name or name fragment> <time ex. 2010-01-01 12:00> <time ex. 2010-01-02 12:00>',
        :proc => Proc.new{ |params| ImProcessor.instance.city_calculate_periodical_stats( params ) },
        #:restricted => false
      },
      {
        :command => ['queue'],
        :desc => 'get queue',
        :usage_desc => '',
        :proc => Proc.new{ |params| get_queue },
        #:restricted => false
      },
    ]
  end

  # Text used when bot receive wrong command
  def wrong_command
    "Wrong command, try 'help'"
  end

  # Help for jabber commands
  def commands_help
    str = ""
    @commands.each do |c|
      # command
      str += c[:command].collect{|d| "'#{d}'"}.join(", ")
      # parameters, not all commands need them
      str += " #{c[:usage_desc]}" unless c[:usage_desc].nil?
      # parameters, not all commands need them
      str += " #{c[:desc]}"

      str += " \n"
    end
    return str
  end

  # Get queue when possible
  # Show it with some like human format
  def get_queue
    begin
      data = Supervisor.instance.get_queue
      str = "Queue size: #{data.size} \n"
      str += data.collect{|d| "#{d.command.inspect}, #{d.status}, #{d.process_time}"}.join("\n")
      str
    rescue => e
      # TODO create 'puts_exception' function near adv_logger
      puts e.inspect
      puts e.backtrace
      # TODO
      # i'm not sure, but when it is direct it could be not available
      # require needed
      'Not available when using direct ImCommandResolver'
    end
  end
end
