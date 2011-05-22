#!/usr/bin/ruby
#encoding: utf-8

# HomeIO - home control system.
# Copyright (C) 2011 Aleksander Kwiatkowski
#
# This file is part of HomeIO.
#
# HomeIO is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# HomeIO is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with HomeIO.  If not, see <http://www.gnu.org/licenses/>.

require "lib/communication/db/extractor_basic_object"
require "lib/measurements/measurement_fetcher"
require "lib/action/action_manager"
require "lib/overseer/overseer_manager"

class HomeIoStandardCommands

  # Command list
  def self.commands
    # main String of command
    #:command => ['help', '?']
    # String description what does it
    #:desc => 'this help'
    # Proc execution of command
    #:proc => Proc.new { |params| HomeIoStandardWorker.commands }
    # Proc process :proc result to String value
    #:string_proc => Proc.new { |resp| resp.inspect }
    # needed some auth., not implemented yet
    #:restricted => false
    # run always now, probably not implemented yet
    #:now => true # no wait command

    [
      # new backend-frontend communication
      {
        :command => ['meas', 'm'],
        :desc => 'measurements',
        :proc => Proc.new { |params| MeasurementFetcher.instance.get_last_hash },
        :string_proc => Proc.new { |resp| string_commands(resp) },
        :restricted => false,
        :now => true # no wait command
      },
      {
        :command => ['meas_by_type', 'mt'],
        :desc => 'measurements of type',
        :proc => Proc.new { |params| MeasurementFetcher.instance.get_hash_by_name( params ) },
        :string_proc => Proc.new { |resp| string_commands(resp) },
        :restricted => false,
        :now => true # no wait command
      },
      {
        :command => ['action_execute'],
        :desc => 'measurements of type',
        :proc => Proc.new { |params| ActionManager.instance.get_action_by_name( params[0] ).execute( params[1] ) },
        :string_proc => Proc.new { |resp| string_commands(resp) },
        :restricted => true, # TODO
        :now => true # no wait command
      },
      {
        :command => ['overseers'],
        :desc => 'list of backend overseers',
        :proc => Proc.new { |params| OverseerManager.instance.overseers },
        :string_proc => Proc.new { |resp| string_commands(resp) },
        :restricted => true, # TODO
        :now => true # no wait command
      },

        
      # TODO old command, update to current HomeIO
      {
        :command => ['help', '?'],
        :desc => 'this help',
        :proc => Proc.new { |params| HomeIoStandardCommands.commands },
        :string_proc => Proc.new { |resp| string_commands(resp) },
        :restricted => false,
        :now => true # no wait command
      },
      {
        :command => ['c', 'cities'],
        :desc => 'list of all cities',
        :proc => Proc.new { |params| ExtractorBasicObject.instance.get_cities },
        :restricted => false
      },
      {
        # 'system' command
        :command => ['queue'],
        :desc => 'get queue',
        :proc => Proc.new { |params| nil },
        :restricted => false
      },
      {
        :command => ['ci'],
        :desc => 'city basic statistics (weather and metar counts, first and last)',
        :params_desc => [
          'id, metar code, name or name fragment'
        ],
        :proc => Proc.new { |params| ExtractorBasicObject.instance.city_basic_info(params[0]) },
        :restricted => false
      },
      {
        :command => ['cix'],
        :desc => 'city advanced statistics (weather and metar counts, first and last, min/max/avg temperature and wind)',
        :params_desc => [
          '<id, metar code, name or name fragment>'
        ],
        :proc => Proc.new { |params| ExtractorBasicObject.instance.city_adv_info(params[0]) },
        :restricted => false
      },
      {
        :command => ['wmc'],
        :desc => 'last metar data for city',
        :params_desc => [
          '<id, metar code, name or name fragment>'
        ],
        :proc => Proc.new { |params| ExtractorBasicObject.instance.get_last_metar(params[0]) },
        :restricted => false
      },
      {
        :command => ['wms'],
        :desc => 'metar summary of all cities',
        :proc => Proc.new { |params| ExtractorBasicObject.instance.summary_metar_list },
        :restricted => false
      },
      {
        :command => ['wma'],
        :desc => 'get <count> last metars for city',
        :params_desc => [
          '<id, metar code, name or name fragment>',
          '<count>'
        ],
        :proc => Proc.new { |params| ExtractorBasicObject.instance.get_array_of_last_metar(params[0], params[1]) },
        :restricted => false
      },
      {
        :command => ['wra'],
        :desc => 'get <count> last weather (non-metar) data for city',
        :params_desc => [
          '<id, metar code, name or name fragment> <count>'
        ],
        :proc => Proc.new { |params| ExtractorBasicObject.instance.get_array_of_last_weather(params[0], params[1]) },
        :restricted => false
      },
      {
        :command => ['wmsr'],
        :desc => 'search for metar data for city at specified time',
        :params_desc => [
          '<id, metar code, name or name fragment>',
          '<date ex. 2010-01-01, or Time object>',
          '<time ex. 12:00, or nothing>'
        ],
        :proc => Proc.new { |params| ExtractorBasicObject.instance.search_wma(params[0], params[1], params[2]) },
        :restricted => false
      },
      {
        :command => ['wrsr'],
        :desc => 'search for weather (non-metar) data for city at specified time',
        :params_desc => [
          '<id, metar code, name or name fragment>',
          '<date ex. 2010-01-01, or Time object>',
          '<time ex. 12:00, or nothing>'
        ],
        :proc => Proc.new { |params| ExtractorBasicObject.instance.search_wa(params[0], params[1], params[2]) },
        :restricted => false
      },
      {
        :command => ['wsr'],
        :desc => 'search for weather (metar or non-metar) data for city at specified time',
        :params_desc => [
          '<id, metar code, name or name fragment>',
          '<date ex. 2010-01-01, or Time object>',
          '<time ex. 12:00, or nothing>'
        ],
        :proc => Proc.new { |params| ExtractorBasicObject.instance.search_metar_or_weather(params[0], params[1], params[2]) },
        :restricted => false
      },
      {
        :command => ['cps'],
        :desc => 'calculate city periodical stats (metar or non-metar) at specified time interval',
        :params_desc => [
          '<id, metar code, name or name fragment>',
          '<date from ex. 2010-01-01, or Time object>',
          '<time from ex. 12:00, or nothing>',
          '<date to ex. 2010-01-01, or Time object>',
          '<time to ex. 12:00, or nothing>'
        ],
        :proc => Proc.new { |params| ExtractorBasicObject.instance.city_calculate_periodical_stats(
          params[0],
          params[1], params[2],
          params[3], params[4]
        ) },
        :restricted => false
      },
    ]
  end

  # Process command list to String
  def self.string_commands( res )
    str = ""
    res.each do |c|
      params = ""
      params = c[:params_desc].join(' ') if c[:params_desc].kind_of? Array
      line = "#{c[:command].join(", ")} - #{c[:desc]}, usage ex. '#{c[:command].first} #{params}'".strip + "\n"
      str += line
    end
    return str
  end


end