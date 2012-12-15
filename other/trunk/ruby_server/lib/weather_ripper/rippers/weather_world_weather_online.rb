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
require 'json'
require File.join Dir.pwd, 'lib/utils/core_classes'
require File.join Dir.pwd, 'lib/storage/storage_active_record'
require File.join Dir.pwd, 'lib/utils/config_loader'

# WorldWeatherOnline special weather processor

class WeatherWorldWeatherOnline
  include Singleton
  
  def initialize
    @api = ConfigLoader.instance.config('WorldWeatherOnlineApiKey')[:api_key]
    @enabled = ConfigLoader.instance.config('WorldWeatherOnlineApiKey')[:enabled]

    StorageActiveRecord.instance
    sleep(0.5)

    # prepare provider id
    wp = WeatherProvider.find_or_create_by_name(provider_name)
    wp.save!
    @id = wp.id

    # will be loaded later
    @cities = nil
  end

  def provider_name
    "WorldWeatherOnline"
  end

  # TODO probably not used
  def first_check
    # get all cities
    @cities = City.all
    if not @city.nil?
      load_city(@cities.first)
    else
      puts "#{self.class} disabled - no cities"
      @enabled = false
    end
  end

  def check_all
    return unless @enabled == true
    # load all cities
    @cities = City.all if @cities.nil?

    @cities.each do |c|
      load_city(c)
    end
  end

  def load_city(city)
    url = "http://free.worldweatheronline.com/feed/weather.ashx?key=#{@api}&q=#{city.lat},#{city.lon}&num_of_days=2&format=json"
    body = Net::HTTP.get(URI.parse(url))
    result = JSON.parse(body)

    # weather archives as processing output
    weather_archives = Array.new

    # fix for empty response
    return if result.nil? or result["data"].nil? or result["data"]["current_condition"].nil?

    # current conditions
    current = result["data"]["current_condition"].first
    current_time = Time.create_time_from_string_12_utc(nil, current["observation_time"])

    h = process_node(current)
    h.merge(
      {
        :city_id => city.id,
        :time_from => current_time - 1.hour,
        :time_to => current_time,
      }
    )
    w_current = WeatherArchive.new(h)
    weather_archives << w_current

    # prediction
    predictions = result["data"]["weather"]
    predictions.each do |p|
      h = process_node(p)
      h[:pressure] = nil
      h[:city_id] = city.id

      # create 2 records using tempMinC and tempMaxC
      hl = h.merge(
        {
          :time_from => Time.create_time_from_string(p["date"], "0:00") - 4.hours,
          :time_to => Time.create_time_from_string(p["date"], "0:00") + 8.hours,
          :temperature => p["tempMinC"].to_i
        }
      )
      w = WeatherArchive.new(hl)
      weather_archives << w

      # and high
      hh = h.merge(
        {
          :time_from => Time.create_time_from_string(p["date"], "0:00") + 8.hours,
          :time_to => Time.create_time_from_string(p["date"], "0:00") + 20.hours,
          :temperature => p["tempMaxC"].to_i
        }
      )
      w = WeatherArchive.new(hh)
      weather_archives << w

    end

    weather_archives.each do |w|
      StorageActiveRecord.instance.store_ar_object(w)
    end

    puts "Stored: #{self.class.to_s}: #{city.name}: #{weather_archives.size} records"
  end

  private

  # Process json node to Hash for AR
  def process_node(node)
    return {
      :temperature => node["temp_C"].to_i,
      :wind => node["windspeedKmph"].to_f / 3.6,
      :pressure => node["pressure"].to_f / 3.6,
      :rain => node["precipMM"].to_f / 3.6,
      :snow => nil,
      :weather_provider_id => @id
    }
  end

end
