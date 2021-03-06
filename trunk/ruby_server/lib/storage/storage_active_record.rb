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

require File.join Dir.pwd, 'lib/utils/core_classes'
require File.join Dir.pwd, 'lib/storage/storage_db_abstract'
require 'rubygems'
require 'active_record'
require 'singleton'
require 'acts_as_commentable'
require File.join Dir.pwd, 'lib/utils/start_threaded'
require File.join Dir.pwd, 'lib/storage/measurement_storage'

# it is better for code completion
require File.join Dir.pwd, "lib/storage/active_record/backend_models/city"
require File.join Dir.pwd, "lib/storage/active_record/backend_models/meas_archive"
require File.join Dir.pwd, "lib/storage/active_record/backend_models/meas_type"
require File.join Dir.pwd, "lib/storage/active_record/backend_models/action_event"
require File.join Dir.pwd, "lib/storage/active_record/backend_models/action_type"
require File.join Dir.pwd, "lib/storage/active_record/backend_models/weather_archive"
require File.join Dir.pwd, "lib/storage/active_record/backend_models/weather_metar_archive"
require File.join Dir.pwd, "lib/storage/active_record/backend_models/weather_provider"
require File.join Dir.pwd, "lib/storage/active_record/backend_models/overseer"
require File.join Dir.pwd, "lib/storage/active_record/backend_models/overseer_parameter"

require_files_from_directory("lib/storage/active_record/")

# Storage using custom active record connection
# Just like the Rails :)
#
# Store every object instantly, no pooling

class StorageActiveRecord < StorageDbAbstract
  include Singleton

  # Connection is ready
  attr_reader :ready

  # TODO fix sleeps
  def initialize
    super
    # I don't know if it is needed, concurrency fix
    @mutex = Mutex.new if @mutex.nil?
    sleep 0.05

    # mutex
    @mutex.synchronize do
      # only execute when nil
      if @ready.nil?
        @ready = false

        # always enabled
        @config[:enabled] = true

        ActiveRecord::Base.establish_connection(
          @config[:connection]
        )

        @pool = Array.new
        @ready = true

        # wait for AR initialization on slow pc
        sleep @config[:init_time].to_f
      end

      # if other tries to execute - wait for it
      while not @ready == true
        sleep 0.1
      end
    end
  end

  # Start measurement pool and special thread for saving objects
  def measurement_initialize(measurement_save_interval)
    if @measurement_pool.nil?
      @measurement_pool = Array.new
      @measurement_rt = StartThreaded.start_threaded(measurement_save_interval, self) do
        measurement_pool_flush
      end
    end
  end

  # Create tables in DB
  def init
    Dir["lib/storage/active_record/migrations/*.rb"].each { |file| require file }
    ActiveRecordInitMigration.up
  end

  # Drop tables in DB
  def destroy
    Dir["lib/storage/active_record/migrations/*.rb"].each { |file| require file }
    ActiveRecordInitMigration.down
  end

  # Store object
  def store(obj)
    case obj.class.to_s
      when 'MetarCode' then
        store_metar(obj)
      when 'Weather' then
        store_weather(obj)
      when 'MeasArchive'
        # MeasArchive is AR object, store in special pool which is saved every small amount of time (5-20 seconds)
        store_measurement(obj)
      else
        other_store(obj)
    end

    check_pool_size
  end

  # Add ActiveRecord object to pool without processing it
  def store_ar_object(obj)
    @pool << obj
    check_pool_size
  end

  # Flush object from pool to DB
  def flush
    # saving each object
    puts "StorageActiveRecord flushing #{@pool.size} objects"
    t = Time.now
    ActiveRecord::Base.transaction do
      @pool.each do |o|
        res = o.save

        if res == false
          err_msg = "StorageActiveRecord errors: #{o.errors.inspect} (#{o.inspect})"
          puts err_msg
          AdvLog.instance.logger(self).warn("#{err_msg}   -   #{o.inspect}")
          # TODO move it outside, more type of error handling
        end
      end
    end
    puts "#{self.class.to_s} - storing #{@pool.size} object - #{Time.now.to_f - t.to_f} s" if SHOW_STORAGES_TIME_INFO

    # clearing pool
    @pool = Array.new
  end

  # Set flag if this city stores metar or weather
  # When city has no metars and we want to find metar it has to search through
  # all record which is log task
  def update_logged_flag
    City.update_search_flags_for_all_cities
  end

  # Set flag if this city stores metar or weather
  # When city has no metars and we want to find metar it has to search through
  # all record which is log task
  #
  # Old version
  def update_logged_flag_old
    cities = CityProxy.instance.cities_array
    cities.each do |ch|
      wa = WeatherArchive.find(:last, :conditions => { :city_id => ch[:id] })
      wma = WeatherMetarArchive.find(:last, :conditions => { :city_id => ch[:id] })
      c = City.find_by_id(ch[:id])

      c.update_attributes!(
        {
          :logged_metar => !wma.nil?,
          :logged_weather => !wa.nil?,
        }
      )
    end
  end

  private

  # Check pool size and perform flush
  def check_pool_size
    # flushing
    if @pool.size >= @config[:pool_size].to_i
      flush
    end
  end

  # Store metar weather data by adding it object pool
  #
  # :call-seq:
  #   store_metar( MetarCode )
  def store_metar(obj)
    # wrong records can be not saved - there are always raw metars in text files
    return unless obj.valid?
    shortened_raw = obj.raw.shorten_in_whitespace(200)
    h = {
      :time_from => obj.time_from,
      :time_to => obj.time_to,
      :temperature => obj.temperature,
      :pressure => obj.pressure,
      :wind => obj.wind,
      :snow_metar => obj.snow_metar,
      :rain_metar => obj.rain_metar,
      :raw => shortened_raw,
      :city_id => obj.city_id,
    }
    # updating metar if stored in DB
    wma = WeatherMetarArchive.find(
      :last,
      :conditions => {
        :city_id => obj.city_id,
        :time_from => obj.time_from,
        #:raw => shortened_raw # it shouldn't be modified but let assume it can (shortening, wrong char removal)
      }
    )
    if wma.nil?
      wma = WeatherMetarArchive.new(h)
    else
      wma.update_attributes(h)
    end

    @pool << wma
  end

  def store_weather(obj)
    # wrong records can be not saved - there are always raw metars in text files
    return unless obj.valid?
    h = {
      :time_from => obj.data[:time_from],
      :time_to => obj.data[:time_to],
      :temperature => obj.data[:temperature],
      :pressure => obj.data[:pressure],
      :wind => obj.data[:wind],
      :snow => obj.data[:snow],
      :rain => obj.data[:rain],
      :city_id => obj.definition[:id],
      :weather_provider_id => obj.data[:weather_provider_id]
    }
    # updating metar if stored in DB
    wa = WeatherArchive.find(
      :last,
      :conditions => {
        :city_id => obj.definition[:id],
        :time_from => obj.data[:time_from],
        :weather_provider_id => obj.data[:weather_provider_id]
      }
    )

    if wa.nil?
      wa = WeatherArchive.new(h)
    else
      wa.update_attributes(h)
    end

    @pool << wa
  end

  # Add to special pool for measurements
  def store_measurement(ma)
    @measurement_pool << ma
  end

  # Flush measurement pool, executed by internal thread
  def measurement_pool_flush
    pool_size = @measurement_pool.size
    ActiveRecord::Base.transaction do
      @measurement_pool.each do |o|
        res = o.save
        # measurements will be stored in Measurements.json when 'something went wrong'
        if res == false
          measurement_save_object_when_db_failed(o)
        end
      end
    end
    @measurement_pool = Array.new
    puts "Measurement pool flushed, count #{pool_size}"
  end

  # Emergency store in json
  def measurement_save_object_when_db_failed(ma)
    MeasurementStorage.instance.store(ma)
  end

end
