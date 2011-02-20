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

class HomeIoStandardCommands
  # Command list
  def self.commands
    [
      {
        :command => ['help', '?'],
        :desc => 'this help',
        :proc => Proc.new { |params| HomeIoStandardWorker.commands },
        :restricted => false
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
        :usage_desc => [
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

  
end