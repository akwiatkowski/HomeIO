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

require "lib/communication/db/extractor_active_record"

# Wrap extractor to communicate only using basic object (Hashes, Arrays)
# So no AR objects will be send via sockets

class ExtractorBasicObject < ExtractorActiveRecord

  # Get all cities
  LAST_METAR_DEFAULT_COUNT = 20

  def get_cities
    cities = super
    attrs = cities.collect { |c| {
      :name => c.attributes["name"],
      :country => c.attributes["country"],
      :lat => c.attributes["lat"],
      :lon => c.attributes["lon"],
      :id => c.attributes["id"],
    } }
    return attrs
  end

  # City basic statistics
  def city_basic_info(city)
    res = super(city)
    return convert_ar_objects(res)
  end

  # City advanced statistics
  def city_adv_info(city)
    res = super(city)
    return convert_ar_objects(res)
  end

  # Last metar data for city. Return object fetched from DB and processed raw
  #
  # :call-seq:
  #   get_last_metar( String city ) => {:db => Hash from WeatherMetarArchive, :metar_code => Hash from MetarCode
  def get_last_metar(city)
    res_from_db = super(city)
    return nil if res_from_db.nil?
    return {
      :db => convert_ar_objects(res_from_db),
      :city => convert_ar_objects(res_from_db.city),
      :metar_code => res_from_db.process_raw_to_metar_code.to_hash
    }
  end

  # Last metar summary for all cities, only within last 6 hours
  def summary_metar_list
    res = super
    return convert_ar_objects(res)
  end

  # Get array of last metar data
  def get_array_of_last_metar(city, last_count = LAST_METAR_DEFAULT_COUNT)
    res = super(city, last_count)
    return convert_ar_objects(res)
  end

  # Get table data of last weather data
  def get_array_of_last_weather(city, last_count)
    res = super(city, last_count)
    return convert_ar_objects(res)
  end

  # Search nearest WeatherMetarArchive
  #
  # :call-seq:
  #   search_wma( String city, String date, String time) => WeatherMetarArchive or nil
  #   search_wma( String city, Time) => WeatherMetarArchive or nil
  def search_wma(city, date_string_or_time, time_string = '0:00')
    if date_string_or_time.kind_of? Time
      time = date_string_or_time
    else
      time = Time.create_time_from_string(date_string_or_time, time_string)
    end
    res = super(city, time)
    return convert_ar_objects(res)
  end

  # Search nearest WeatherArchive
  #
  # :call-seq:
  #   search_wa( String city, String date, String time) => WeatherArchive or nil
  #   search_wa( String city, Time) => WeatherArchive or nil
  def search_wa(city, date_string_or_time, time_string = '0:00')
    if date_string_or_time.kind_of? Time
      time = date_string_or_time
    else
      time = Time.create_time_from_string(date_string_or_time, time_string)
    end
    res = super(city, time)
    return convert_ar_objects(res)
  end

  private

  # Convert data structure to not have active record object. Instead of them it return attributes.
  def convert_ar_objects(obj)
    case obj.class.to_s
      when 'Hash' then
        obj.keys.each do |k|
          obj[k] = convert_ar_objects(obj[k])
        end
        return obj

      when 'Array' then
        (0...(obj.size)).each do |i|
          obj[i] = convert_ar_objects(obj[i])
        end
        return obj

      else
        if obj.kind_of? ActiveRecord::Base
          # convert keys to symbols
          attrs = obj.attributes
          h = Hash.new
          attrs.keys.each do |k|
            h[k.to_sym] = attrs[k]
          end
          return h
        else
          return obj
        end

    end
  end
end