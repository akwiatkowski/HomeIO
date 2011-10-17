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


# Background task used for creating graphs: weather, measurements, maybe others too

class GraphTask

  # for future version
  FETCH_INTERVAL = 1.day

  # where store graphs and semi-outputs
  DIR_PATH = File.join(Rails.root, "tmp", "graphs")

  def initialize(params, session, options = { })
    @params = params
    @user_id = session[:user_id]
    @options = options
  end

  attr_reader :params

  def time_from
    if @time_from.nil?
      begin
        @time_from = params[:time_from].to_time
      rescue
        @time_from = time_to - 10.minutes
      end
    end
    return @time_from
  end

  def time_to
    if @time_to.nil?
      begin
        @time_to = params[:time_to].to_time
      rescue
        @time_to = Time.now
      end
    end
    return @time_to
  end

  def perform
    begin
      perform_inside
    rescue => e
      puts e.inspect
      puts e.backtrace
    end
  end

  def perform_inside
    @task = UserTask.new(
      {
        :user_id => @user_id,
        :params => params,
        :delayed_job => @delayed_job_id
      })
    @task.save!

    puts "Starting GraphTask, id #{@task.id}"

    layers = fetch_data
    puts "Data fetched, id #{@task.id}"

    # create dir for outputs
    Dir.mkdir(DIR_PATH) if not File.exists?(DIR_PATH)
    file_name = File.join(DIR_PATH, "#{@task.id}.yml")
    File.open(file_name, 'w') do |out|
      out.write(layers.to_yaml)
    end
    puts "Data save to #{file_name}, id #{@task.id}"

    # create graph
    file_name = File.join(DIR_PATH, "#{@task.id}.png")
    create_graphs(layers, file_name)
    puts "Graph created #{file_name}, id #{@task.id}"

  end

  # Connect with DelayedJob
  def delayed_job_id=(did)
    # whatever is first
    if @task.nil?
      @delayed_job_id = did
    else
      @task.update_attribute(:delayed_job_id, did)
    end
  end

  def klass=(k)
    @task.update_attribute(:klass, dj.id)
  end


  # First part, fetching data from DB
  def fetch_data
    layers = Array.new

    if params[:meas_type_group_id]
      # selected types
      klass = 'MeasTypeGroup'
      types = MeasTypeGroup.find(params[:meas_type_group_id]).types
      types.each do |type|
        layers << fetch_measurement_type(type)
      end
    end
    if params[:meas_type_id]
      # one type
      klass = 'MeasType'
      type = MeasType.find(params[:meas_type_id])
      layers << fetch_measurement_type(type)
    end
    if params[:city_id]
      klass = 'City' # TODO or WeatherArchive / WeatherMetarArchive
      city = City.find(params[:city_id])
      type = params[:type] || 'temperature'
      layers << fetch_weather_data(city, type)
    end

    return layers
  end

  # Fetch measurements to layer
  def fetch_measurement_type(type)
    conditions = [
        "meas_type_id = ? and time_from >= ? and time_from <= ?",
        type.id,
        time_from,
        time_to
      ]
    puts "Fetching measurements, conditions #{conditions.inspect}"
    measurements = MeasArchive.where(conditions).all

    meas_data = Array.new
    measurements.each do |m|
      meas_data << {
        :x => Time.now.to_f - (m.time_from.to_f + m.time_to.to_f) / 2.0,
        :y => m.value
      }
    end

    layer_options = {
      :label => type.name_human + " [#{type.unit}]"
    }

    layer = {
      :data => meas_data,
      :options => layer_options
    }

    return layer
  end

  # Fetch weather data
  def fetch_weather_data(city, type)
    weather_db_data = Array.new

    # choose class depends on city definition
    weather_klass = nil
    if city.logged_metar
      weather_klass = WeatherMetarArchive
    elsif city.logged_weather
      weather_klass = WeatherArchive
    end

    # fetch if city has any weather data
    if not weather_klass.nil?
      conditions = [
          "city_id = ? and time_from >= ? and time_from <= ?",
          city.id,
          time_from,
          time_to
        ]
      puts "Fetching weather data, conditions #{conditions.inspect}"
      weather_db_data = weather_klass.where(conditions).all

    end

    # TODO it would be nice to crate something that translate snow to snow_metar when needed

    weather_data = Array.new
    weather_db_data.each do |w|
      weather_data << {
        :x => Time.now.to_f - (m.time_from.to_f + m.time_to.to_f) / 2.0,
        :y => m.attributes[type.to_sym]
      }
    end

    layer_options = {
      :label => type.humanize
    }

    layer = {
      :data => weather_data,
      :options => layer_options
    }

    return layer
  end

  # Create sweet graph
  def create_graphs(layers, file_path)
    tg = TechnicalGraph.new
    layers.each do |l|
      tg.add_layer(l[:data], l[:options])
    end
    tg.render
    tg.image_drawer.save_to_file(file_path)
  end


  ## What is returned when user was not polite
  #EMPTY = {
  #  :meas => []
  #}
  #
  ## Standard project wide options for graph
  #GRAPH_STD_OPTIONS = UniversalGraph::STD_OPTIONS
  #
  #ADMIN_USER_LIMIT = 500_000
  #REGULAR_USER_LIMIT = 20_000
  #
  ## Load measurements, create graph when needed
  #def self.find(params, user)
  #  return EMPTY if params[:time_from].blank? or params[:time_to].blank? or params[:meas_type_group_id].blank?
  #  time_from = params[:time_from].to_time
  #  time_to = params[:time_to].to_time
  #  meas_type_group_id = params[:meas_type_group_id].to_i
  #  antialias = params[:antialias] == 'true'
  #  format = params[:format]
  #
  #  # output, and place to store all useful variables
  #  hash_output = Hash.new
  #  meas = Array.new
  #
  #  group = MeasTypeGroup.find(meas_type_group_id)
  #  group.meas_types.each do |mt|
  #    puts "Fetching type #{mt.name}"
  #
  #    mh = {
  #      :meas_type => mt,
  #      :meas_archives => MeasArchive.where(
  #        ["meas_type_id = ? and time_from between ? and ?", mt.id, time_from, time_to]
  #      ).limit(meas_archive_limit(user)).all
  #    }
  #    meas << mh
  #  end
  #  puts "Fetching phase complete"
  #
  #  puts format, "\n\n\n"
  #
  #  if format == 'png' or format == 'svg'
  #    # create graph
  #    h = GRAPH_STD_OPTIONS.clone.merge(
  #      {
  #        :x_max => 0.0, # because max is 0, time_to = now
  #
  #        :x_axis_label => 'hours',
  #        :y_axis_label => 'value',
  #
  #        :x_axis_interval => 3600,
  #        :y_axis_count => group.y_interval,
  #        :x_axis_fixed_interval => true,
  #        :y_axis_fixed_interval => false,
  #        :width => 8000,
  #        :height => 2000,
  #
  #        :y_min => group.y_min,
  #        :y_max => group.y_max,
  #
  #        :layers_antialias => antialias,
  #        :font_antialias => antialias,
  #        :layers_antialias => antialias,
  #
  #        :legend => true,
  #        :legend_auto => true,
  #        :legend_width => 140,
  #        :legend_margin => 60,
  #
  #        :axis_density_enlarge_image => true,
  #        :x_axis_min_distance => 60,
  #        :y_axis_min_distance => 40,
  #      }
  #    )
  #
  #    # process measurements and adding layers
  #    tg = TechnicalGraph.new(h)
  #
  #    meas.each do |m|
  #      data = Array.new
  #      m[:meas_archives].each do |w|
  #        data << { :x => (w.time_from - Time.now)/3600, :y => w.value }
  #        # current measurements has identical times
  #        if not w.time_from == w.time_to
  #          data << { :x => (w.time_to - Time.now)/3600, :y => w.value }
  #        end
  #      end
  #
  #      layer_params = {
  #        :antialias => antialias,
  #        :label => m[:meas_type].name_human
  #      }
  #
  #      puts "Adding layer #{m[:meas_type].name_human}"
  #      tg.add_layer(data, layer_params)
  #      puts "Layer added"
  #    end
  #
  #    puts "Graph rendered"
  #    tg.render
  #
  #    if format == 'png'
  #      hash_output[:graph] = tg.image_drawer.to_png
  #    end
  #
  #    if format == 'svg'
  #      # not implemented in library yet
  #      #hash_output[:graph] = tg.image_drawer.to_svg
  #    end
  #  end
  #
  #  # limited output
  #  hash_output[:meas] = Array.new
  #  meas.each do |m|
  #    hash_output[:meas] << {
  #      :meas_type => m[:meas_type],
  #      :time_from => time_from,
  #      :time_to => time_from,
  #      :meas_type_group => group,
  #      :meas_archives_count => m[:meas_archives].size
  #    }
  #  end
  #
  #  return hash_output
  #end
  #
  ## Admin users can start processing bigger requests
  #def self.meas_archive_limit(user)
  #  return ADMIN_USER_LIMIT if user.admin?
  #  return REGULAR_USER_LIMIT
  #end
  #
  #def self.process_meas_group(meas_data, antialias = false)
  #  data = Array.new
  #
  #  t = meas_data.sort { |a, b| a.time_from <=> b.time_from }
  #  if (t.last.time_from - t.first.time_from) > 120.0
  #    minutes = true
  #  end
  #
  #  if minutes
  #    x_label = "minutes, time"
  #    divider = 60.0
  #    x_interval = 1.0
  #  else
  #    x_label = "10 seconds, time"
  #    divider = 1.0
  #    x_interval = 10.0
  #  end
  #
  #  meas_data.each do |w|
  #    data << { :x => (Time.now - w.time_from) / divider, :y => w.value }
  #    # current measurements has identical times
  #    if not w.time_from == w.time_to
  #      data << { :x => (Time.now - w.time_to) / divider, :y => w.value }
  #    end
  #  end
  #
  #  xs = data.collect { |d| d[:x] }
  #  ys = data.collect { |d| d[:y] }
  #
  #
  #  tg.add_layer(data)
  #  tg.render
  #
  #  return tg.image_drawer.to_png
  #end

end