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

require 'singleton'
require 'lib/storage/storage'
require 'lib/metar/metar_code'

# Retrieve data from DB

class ExtractorActiveRecord
  include Singleton

  def initialize
    @config = ConfigLoader.instance.config('ExtractorActiveRecord')
    StorageActiveRecord.instance
  end

  # Get all cities
  def get_cities
    return City.find(:all, :conditions => { }, :order => 'calculated_distance DESC')
  end

  # Alias for using not overrode method
  alias_method :_get_cities, :get_cities

  # Search city
  #
  # :call-seq:
  #   search_city( city id from DB ) => City instance of nil
  #   search_city( name ) => City instance of nil
  #   search_city( metar code ) => City instance of nil
  #   search_city( part of name ) => City instance of nil
  def search_city(city)
    c = City.find_by_id(city)
    c = City.find_by_name(city) if c.nil?
    c = City.find_by_metar(city) if c.nil?
    c = City.find(:first, :conditions => ["lower(name) like lower(?)", "%#{city}%"]) if c.nil?
    return c
  end

  # Get last metar for city
  #
  # :call-seq:
  #   get_last_metar( city id from DB ) => City instance of nil
  def get_last_metar(city)
    c = search_city(city)
    # when not found
    return nil if c.nil?
    # when city has no metars
    return nil if true == @config[:lazy_search] and false == c.logged_metar # lazy search

    return WeatherMetarArchive.find(:first, :conditions => { :city_id => c.id }, :order => 'time_from DESC')
  end

# Basic city information: weather and metar counts, first and last
  def city_basic_info(city)
    c = search_city(city)
    return nil if c.nil?

    # lazy searching, not lazy, but efficient! :]
    if true == @config[:lazy_search] and false == c.logged_metar
      metar_count = 0
      first_metar = nil
      last_metar = nil
    else
      metar_count = WeatherMetarArchive.count(:all, :conditions => { :city_id => c.id })
      first_metar = WeatherMetarArchive.find(:first, :conditions => { :city_id => c.id }, :order => 'time_from ASC')
      last_metar = WeatherMetarArchive.find(:last, :conditions => { :city_id => c.id }, :order => 'time_from ASC')
    end

    if true == @config[:lazy_search] and false == c.logged_weather
      weather_count = 0
      first_weather = nil
      last_weather = nil
    else
      weather_count = WeatherArchive.count(:all, :conditions => { :city_id => c.id })
      first_weather = WeatherArchive.find(:first, :conditions => { :city_id => c.id }, :order => 'time_from ASC')
      last_weather = WeatherArchive.find(:last, :conditions => { :city_id => c.id }, :order => 'time_from ASC')
    end

    return {
      :city_object => c,
      :city => c.name,
      :city_country => c.country,
      :city_metar => c.metar,
      :metar_count => metar_count,
      :weather_count => weather_count,
      :first_metar => first_metar,
      :last_metar => last_metar,
      :first_weather => first_weather,
      :last_weather => last_weather
    }
  end


  # Advanced city information. Same as basic city information but also: min/max/avg temperature and wind
  def city_adv_info(city)
    data = city_basic_info(city)
    return nil if data.nil?

    c = data[:city_object]

    #TODO where could be some problem with AR/Hash due to ExtractorBasicObject
    if true == @config[:lazy_search] and true == c[:logged_metar]
      data[:high_temp_metar] = WeatherMetarArchive.find(:first, :conditions => { :city_id => c.id }, :order => 'temperature DESC')
      puts "City Adv Info :high_temp_metar #{Time.now}"
      data[:low_temp_metar] = WeatherMetarArchive.find(:first, :conditions => { :city_id => c.id }, :order => 'temperature ASC')
      puts "City Adv Info :low_temp_metar #{Time.now}"
      data[:high_wind_metar] = WeatherMetarArchive.find(:first, :conditions => { :city_id => c.id }, :order => 'wind DESC')
      puts "City Adv Info :high_wind_metar #{Time.now}"
    end

    if true == @config[:lazy_search] and true == c[:logged_weather]
      data[:high_temp_weather] = WeatherArchive.find(:first, :conditions => { :city_id => c.id }, :order => 'temperature DESC')
      puts "City Adv Info :high_temp_weather #{Time.now}"
      data[:low_temp_weather] = WeatherArchive.find(:first, :conditions => { :city_id => c.id }, :order => 'temperature ASC')
      puts "City Adv Info :low_temp_weather #{Time.now}"
      data[:high_wind_weather] = WeatherArchive.find(:first, :conditions => { :city_id => c.id }, :order => 'wind DESC')
      puts "City Adv Info :high_wind_weather #{Time.now}"
    end

    return data
  end

  # Last metar summary for all cities, only within last 6 hours
  def summary_metar_list
    array = Array.new

    # use alias because 'get_cities' could be overrode
    cities = _get_cities
    cities.each do |c|
      wma = WeatherMetarArchive.find(
        :first,
        :conditions => [
          "city_id = ? and time_from >= ?",
          c.id,
          Time.now - 6*3600
        ],
        :order => 'time_from DESC'
      )
      if not wma.nil?
        array << wma
      end
    end

    return array
  end

  # Get array of last metars
  def get_array_of_last_metar(city, last_count)
    a = Array.new
    c = search_city(city)
    return nil if true == @config[:lazy_search] and false == c.logged_metar # lazy search
    return WeatherMetarArchive.find(
      :all,
      :conditions => { :city_id => c.id },
      :order => 'time_from DESC',
      :limit => last_count
    )
  end

  # Get table data of last weathers
  def get_array_of_last_weather(city, last_count)
    a = Array.new
    c = search_city(city)
    return nil if true == @config[:lazy_search] and false == c.logged_weather # lazy search
    return WeatherArchive.find(
      :all,
      :conditions => { :city_id => c.id },
      :order => 'time_from DESC',
      :limit => last_count,
      :include => :weather_provider
    )
  end

  # Universal searcher, get closest object to +time+ checking within +time_range+
  # seconds. Table should have column 'time_from'
  #
  # DB table need to has column 'time_from'
  #
  # +klass+ - AR class
  # +key_name+ - foreign key column name used for searching
  # +key_value+ - foreign key value
  # +time_range+ - second range for searching, default = 24*3600
  # +time+ - Time for searching 'when'
  #
  # :call-seq:
  #   _search_archived_data(klass, key_name, key_value, time_range, time) => klass instance or nil
  def _search_archived_data(klass, key_name, key_value, time_range, time)
    # TODO rewrite to search between time_from and time_to, not only near time_from

    conditions = [
      "#{key_name} = ? and time_from between ? and ?",
      key_value,
      time - time_range,
      time + 1
    ]
    obj_before = klass.find(:first,
                            :conditions => conditions,
                            :order => 'time_from DESC')

    conditions = [
      "#{key_name} = ? and time_from between ? and ?",
      key_value,
      time - 1,
      time + time_range
    ]
    #puts conditions.inspect
    obj_after = klass.find(:first,
                           :conditions => conditions,
                           :order => 'time_from ASC')

    # nothing found
    if obj_before.nil? and obj_after.nil?
      return nil
    elsif obj_before.nil?
      return obj_after
    elsif obj_after.nil?
      return obj_before
    else

      time_before_diff = (obj_before.time_from - time).abs
      time_after_diff = (obj_after.time_from - time).abs

      if time_before_diff > time_after_diff
        return obj_after
      else
        return obj_before
      end
    end
  end

  # Search nearest WeatherMetarArchive
  def search_wma(city, time)
    c = search_city(city)
    return nil if c.nil?
    return nil if true == @config[:lazy_search] and false == c.logged_metar # lazy search

    return _search_archived_data(WeatherMetarArchive, 'city_id', c.id, 2*24*3600, time)
  end

  ################


  # Convert WeatherMetarArchive to MetarCode
  # Warning: WMA need to has correct metar (.raw)
  def wma_to_metarcode(wma)
    return nil if wma.nil?
    return MetarCode.process_archived(wma.raw, wma.time_from.year, wma.time_from.month)
  end

  # Convert MetarCode to hash
  def metarcode_to_hash(m)
    return nil if m.nil?

    return {
      :city => m.city_hash[:name],
      :city_country => m.city_hash[:country],
      :city_metar => m.city,
      :time => m.output[:time].localtime,
      :wind => m.output[:wind_mps],
      :temperature => m.output[:temperature],
      :pressure => m.output[:pressure],
      :cloudiness => m.output[:cloudiness],
      :rain_metar => m.output[:rain_metar],
      :snow_metar => m.output[:snow_metar],
      :specials => m.output[:specials]
    }
  end

  # Convert WeatherMetarArchive to hash
  # Useful when WMA is without metar (.raw)
  def wma_to_hash(wma)
    return nil if wma.nil?

    c = City.find(wma.city_id)
    return {
      :city => c.name,
      :city_country => c.country,
      :city_metar => c.metar,
      :time => wma.time_from,
      :wind => wma.wind,
      :temperature => wma.temperature,
      :pressure => wma.pressure,
      :rain_metar => wma.rain_metar,
      :snow_metar => wma.snow_metar
    }
  end

  # Try to use MetarCode, if not possible use direct conversion to hash
  def wma_with_metarcode_to_hash(wma)
    hash = wma_to_hash(wma)
    begin
      m = wma_to_metarcode(wma)
      new_hash = metarcode_to_hash(m)
      # if MetarCode is valid it can be used then
      hash = new_hash if m.valid?
    rescue
    end
    return hash
  end


  # Convert WeatherArchive to hash
  def wa_to_hash(wa)
    c = City.find(wa.city_id)
    if not wa.weather_provider_id.nil?
      wp = wa.weather_provider.name
    else
      wp = 'N/A'
    end

    return {
      :city => c.name,
      :city_country => c.country,
      :time => wa.time_from,
      :time_to => wa.time_to,
      :temperature => wa.temperature,
      :wind => wa.wind,
      :pressure => wa.pressure,
      :rain => wa.rain,
      :snow => wa.snow,
      :weather_provider => wp,
      # was this predicted or measured by provider
      :predicted => wa.predicted?
    }
  end


  # Search nearest WeatherArchive
  def search_wa(city, time)
    c = search_city(city)
    return nil if c.nil?
    return nil if true == @config[:lazy_search] and false == c.logged_weather # lazy search

    return _search_archived_data(WeatherArchive, 'city_id', c.id, 2*24*3600, time)
  end

  # Search nearest metar, return hash
  def search_metar(city, time)
    wma = search_wma(city, time)
    return nil if wma.nil?
    return wma_with_metarcode_to_hash(wma)
  end

  # Search nearest weather, return hash
  def search_weather(city, time)
    wa = search_wa(city, time)
    return nil if wa.nil?
    return wa_to_hash(wa)
  end

  # Search metar or weather
  def search_metar_or_weather(city, time)
    hm = search_metar(city, time)
    return hm unless hm.nil?

    hw = search_weather(city, time)
    return hw
  end

  # Very basic city information
  def city_very_basic_info(city)
    c = search_city(city)
    return nil if c.nil?

    return {
      :city_object => c,
      :city => c.name,
      :city_country => c.country,
      :city_metar => c.metar
    }
  end


  # Generate statistics
  #
  # *city_id* - id of city
  # *time_from* - Time from
  # *time_to* - Time to
  # *metar*:
  #   - true - only metar
  #   - false - only weather
  #   - nil - use both of them
  def city_periodical_stats_for_city_name(city, time_from, time_to, metar = nil)
    c = search_city(city)
    return nil if c.nil?

    return city_periodical_stats(c.id, time_from, time_to, metar)
  end

  # Generate statistics
  #
  # *city_id* - id of city
  # *time_from* - Time from
  # *time_to* - Time to
  # *metar*:
  #   - true - only metar
  #   - false - only weather
  #   - nil - use both of them
  def city_periodical_stats(city_id, time_from, time_to, metar = nil)
    # conditions
    # temp
    t_conds = [
      "city_id = ? and time_from >= ? and time_to <= ? and temperature is not null",
      city_id,
      time_from,
      time_to
    ]
    # wind
    w_conds = [
      "city_id = ? and time_from >= ? and time_to <= ? and wind is not null",
      city_id,
      time_from,
      time_to
    ]

    h = Hash.new
    c = City.find(city_id)
    h[:city_id] = c.id
    h[:time_from] = time_from
    h[:time_to] = time_to
    h[:metar_switch] = metar
    h[:lazy_search] = @config[:lazy_search]
    h[:logged_metar] = c.logged_metar
    h[:logged_weather] = c.logged_weather

    if false == @config[:lazy_search] or true == c.logged_metar
      # temperature
      # avg
      h[:t_wma_sum] = WeatherMetarArchive.sum(:temperature, :conditions => t_conds)
      h[:t_wma_count] = WeatherMetarArchive.count(:conditions => t_conds)
      # min/max
      h[:t_wma_max] = WeatherMetarArchive.find(:first, :conditions => t_conds, :order => 'temperature DESC')
      h[:t_wma_min] = WeatherMetarArchive.find(:first, :conditions => t_conds, :order => 'temperature ASC')

      # wind
      # avg
      h[:w_wma_sum] = WeatherMetarArchive.sum(:wind, :conditions => w_conds)
      h[:w_wma_count] = WeatherMetarArchive.count(:conditions => w_conds)
      # max
      h[:w_wma_max] = WeatherMetarArchive.find(:first, :conditions => w_conds, :order => 'wind DESC')
    else
      h[:t_wma_sum] = 0.0
      h[:t_wma_count] = 0
      h[:t_wma_max] = nil
      h[:t_wma_min] = nil

      h[:w_wma_sum] = 0.0
      h[:w_wma_count] = 0
      h[:w_wma_max] = nil
    end

    unless false == @config[:lazy_search] or true == c.logged_weather
      # temperature
      # avg
      h[:t_wa_sum] = WeatherArchive.sum(:temperature, :conditions => t_conds)
      h[:t_wa_count] = WeatherArchive.count(:conditions => t_conds)
      # min/max
      h[:t_wa_max] = WeatherArchive.find(:first, :conditions => t_conds, :order => 'temperature DESC')
      h[:t_wa_min] = WeatherArchive.find(:first, :conditions => t_conds, :order => 'temperature ASC')

      # wind
      # avg
      h[:w_wa_sum] = WeatherArchive.sum(:wind, :conditions => w_conds)
      h[:w_wa_count] = WeatherArchive.count(:conditions => w_conds)
      # max
      h[:w_wa_max] = WeatherArchive.find(:first, :conditions => w_conds, :order => 'wind DESC')
    else
      h[:t_wa_sum] = 0.0
      h[:t_wa_count] = 0
      h[:t_wa_max] = nil
      h[:t_wa_min] = nil

      h[:w_wa_sum] = 0.0
      h[:w_wa_count] = 0
      h[:w_wa_max] = nil
    end

    # sum everything
    if true == metar
      # only metar
      h[:t_sum] = h[:t_wma_sum]
      h[:t_count] = h[:t_wma_count]

      h[:w_sum] = h[:w_wma_sum]
      h[:w_count] = h[:w_wma_count]

      # min/max
      h[:t_min] = h[:t_wma_min]
      h[:t_max] = h[:t_wma_max]
      h[:w_max] = h[:w_wma_max]

    elsif false == metar
      # only weather
      h[:t_sum] = h[:t_wa_sum]
      h[:t_count] = h[:t_wa_count]

      h[:w_sum] = h[:w_wa_sum]
      h[:w_count] = h[:w_wa_count]

      # min/max
      h[:t_min] = h[:t_wa_min]
      h[:t_max] = h[:t_wa_max]
      h[:w_max] = h[:w_wa_max]

    else
      # weather and metar
      h[:t_sum] = h[:t_wa_sum] + h[:t_wma_sum]
      h[:t_count] = h[:t_wa_count] + h[:t_wma_count]

      h[:w_sum] = h[:w_wa_sum] + h[:w_wma_sum]
      h[:w_count] = h[:w_wa_count] + h[:w_wma_count]

      # min/max
      h[:t_min] = h[:t_wma_min]
      h[:t_max] = h[:t_wma_max]
      h[:w_max] = h[:w_wma_max]
      # min/max weather
      # weather is not empty and ( min weather was empty or it wasn't empty but was higher )
      h[:t_min] = h[:t_wa_min] if not h[:t_wa_min].nil? and (h[:t_min].nil? or h[:t_wa_min].temperature < h[:t_min].temperature)
      h[:t_max] = h[:t_wa_max] if not h[:t_wa_max].nil? and (h[:t_max].nil? or h[:t_wa_min].temperature > h[:t_max].temperature)
      h[:w_max] = h[:w_wa_max] if not h[:w_wa_max].nil? and (h[:w_max].nil? or h[:t_wa_min].wind > h[:w_max].wind)
    end

    # calculate average
    h[:t_avg] = h[:t_sum].to_f / h[:t_count] if h[:t_count] > 0
    h[:w_avg] = h[:w_sum].to_f / h[:w_count] if h[:w_count] > 0

    # convert min/max values
    h[:t_min] = { :value => h[:t_min].temperature, :time => h[:t_min].time_from } unless h[:t_min].nil?
    h[:t_max] = { :value => h[:t_max].temperature, :time => h[:t_max].time_from } unless h[:t_max].nil?
    h[:w_max] = { :value => h[:w_max].wind, :time => h[:w_max].time_from } unless h[:w_max].nil?

    return h
  end

  private


end
