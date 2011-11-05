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

require 'rubygems'
require 'lib/utils/adv_log'
require 'lib/utils/config_loader'
require 'json'
require 'technical_graph'

require 'lib/storage/storage_active_record'
require 'lib/storage/active_record/backend_models/city'
require 'lib/storage/active_record/backend_models/weather_archive'
require 'lib/storage/active_record/backend_models/weather_metar_archive'

# Fetch data and create graph for weather
# Class used for prototyping and offline creation of graph
# It uses awesome gem, technical_graph :]

class WeatherGrapher

  GRAPH_OPTIONS = {
    :x_axis_fixed_interval => true,
    :x_axis_interval => 1.0, # default hourly or daily

    :y_axis_fixed_interval => false, # override in meas_type_group to use set interval
    :y_axis_count => 10,

    :x_axis_label => 'time [days]',
    :y_axis_label => 'value',

    :legend => true,
    :legend_auto => true,
    :legend_width => 150,
    :legend_margin => 60,

    :width => 16000,
    :height => 1200
  }

  SAVE_FETCHED_DATA_TO_JSON_FILE = false

  ONE_DAY = 24*3600

  # graph width per one day
  WIDTH_PER_DAY =  24*5

  METAR_TYPES = [
    'wind', 'snow_metar', 'rain_metar', 'temperature'
  ]

  def self.metar_city_year(metar, year)
    StorageActiveRecord.instance

    city = City.find_by_metar(metar)
    id = city.id
    METAR_TYPES.each do |t|
      puts "City #{city.name}, id #{id}, graph type #{t}"

      w = WeatherGrapher.new
      w.both_smooth_and_raw
      w.reset_layers

      w.weather_type = t
      w.time_from = Time.mktime(year) #'2009-01-01 0:00:00'.to_time
      w.time_to = Time.mktime(year + 1) #'2012-01-01 0:00:00'.to_time
      w.city_id = id

      #w.only_smooth
      #w.only_raw
      w.both_smooth_and_raw

      w.fetch_and_create_layer
      w.finish_graph
    end

  end

  # Initialize script
  def initialize
    puts "#{Time.now.to_s(:db)} #{self.class} initializing"
    StorageActiveRecord.instance
    reset_layers
  end

  attr_reader :options

  # Time ranges accessors
  def time_to=(t)
    @time_to = process_time(t)
  end

  def time_from=(t)
    @time_from = process_time(t)
  end

  def city=(c)
    if c.kind_of? Fixnum
      @city = City.find(c)
      return
    end
    if c.kind_of? String
      @city = City.where(["name like '%' || ? || '%' or metar = ?", c, c]).first
      return
    end
  end

  def city_id=(cid)
    @city = City.find(cid)
  end

  def weather_klass
    city.weather_class
  end

  def city_id
    return nil if city.nil?
    city.id
  end

  # Type of weather, temperature, wind, pressure, ...
  def weather_type
    @weather_type || 'temperature'
  end

  attr_writer :weather_type

  attr_reader :city, :time_from, :time_to

  def only_smooth
    @layer_smooth = true
    @layer_raw = false
  end

  def only_raw
    @layer_smooth = false
    @layer_raw = true
  end

  def both_smooth_and_raw
    @layer_smooth = true
    @layer_raw = true
  end

  attr_reader :layer_smooth, :layer_raw


  def prepare_output_filename
    filename_core = "#{city.name}_#{weather_type}_#{time_from.to_s(:db)}_#{time_to.to_s(:db)}"
    return filename_core.gsub(/\W/, '_')
  end

  def check_parameters
    raise 'No city' if city.nil? or city_id.nil?
    raise 'No time_from' if time_from.nil?
    raise 'No time_to' if time_to.nil?
    raise 'City has no weather stored (both metar and weather flags are marked to false)' if weather_klass.nil?
  end

  # New graph
  def reset_layers
    @zero_time = nil
    @days = ((time_to.to_f - time_from.to_f) / ONE_DAY).ceil
    puts "Days in time ranges #{@days}, image width #{@days * WIDTH_PER_DAY}"
    @tg = TechnicalGraph.new(
      GRAPH_OPTIONS.clone.merge(
        {
          :x_min => 0,
          :x_max => @days,
          :width => @days * WIDTH_PER_DAY
        }
      ))
  end

  # Timestamp used for starting
  def zero_time
    @zero_time || Time.now.to_i
  end

  def zero_time=(t)
    @zero_time = process_time(t)
  end

  def fetch_and_create_layer
    check_parameters

    # count
    collection = weather_klass.where(["time_from > ? and time_from < ? and city_id = ?", time_from, time_to, city_id])
    count = collection.count
    puts "#{Time.now.to_s(:db)} Fetching #{count} records"
    data = collection.all
    puts "#{Time.now.to_s(:db)} All data fetched"

    # first time
    first = data.sort{|a,b| a.time_from <=> b.time_from }.first
    # setting zero time only once
    self.zero_time = first.time_from if @zero_time.nil?
    puts "#{Time.now.to_s(:db)} First time #{first.time_from.to_s(:db)}"

    #last time
    last = data.sort{|a,b| a.time_from <=> b.time_from }.last
    puts "#{Time.now.to_s(:db)} Last time #{last.time_from.to_s(:db)}"



    if SAVE_FETCHED_DATA_TO_JSON_FILE
      f = File.new("#{prepare_output_filename}.json", "w")
      f.puts data.to_json
      f.close
      puts "#{Time.now.to_s(:db)} All data stored locally"
    end

    # processing data
    weather_key = weather_type.to_s
    puts "#{Time.now.to_s(:db)} #{weather_type} processing started, #{data.size} records"
    layer_data = data.collect { |d| {
      :x => (d.time_from.to_i - zero_time.to_f) / ONE_DAY,
      :y => d.attributes[weather_key]
    } }
    puts "#{Time.now.to_s(:db)} #{weather_type} data processed"

    lo = Hash.new
    lo[:simple_smoother] = true
    lo[:simple_smoother_level] = 48
    lo[:simple_smoother_strategy] = :gauss
    lo[:simple_smoother_x] = true

    layer_options = {
      :label => "#{weather_type} #{city.name}"
    }

    layer_options_smooth = layer_options.clone.merge(lo)
    layer_options_smooth[:label] += " (smoothed)"

    @tg.add_layer(layer_data, layer_options) if layer_raw
    @tg.add_layer(layer_data, layer_options_smooth) if layer_smooth
  end

  def finish_graph
    @tg.render
    @tg.image_drawer.save_to_file("#{prepare_output_filename}_svg.svg")
    @tg.image_drawer.save_to_file("#{prepare_output_filename}_png.png")
  end

  private

# Process time to proper format
  def process_time(t)
    nt = nil
    if t.kind_of? Fixnum or t.kind_of? Float
      nt = Time.at(t)
    end
    if t.kind_of? Time
      nt = t
    end

    return nt
  end

end

WeatherGrapher.metar_city_year('EPPO', 2011)


