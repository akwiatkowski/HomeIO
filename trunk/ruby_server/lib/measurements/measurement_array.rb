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
require File.join Dir.pwd, "lib/utils/config_loader"
require File.join Dir.pwd, "lib/storage/storage_active_record"
require File.join Dir.pwd, 'lib/measurements/measurement_type'

# Store all type of measurements here. Start and stop threads.

class MeasurementArray
  include Singleton

  # Is fetching threads running
  attr_reader :running

  # Minimum interval for one thread
  MIN_ONE_THREAD_INTERVAL = 0.1

  # Load configuration and initialize measurement type objects.
  def initialize
    StorageActiveRecord.instance

    @running = false
    # types
    @types = Array.new
    @config = ConfigLoader.instance.config(self)

    # prepare measurement pool in StorageActiveRecord
    StorageActiveRecord.instance.measurement_initialize( @config[:measurement_pool_flush_interval] )

    initialize_type
  end

  # Configuration array of types
  def config_array
    @config[:array]
  end

  # Array of MeasurementType
  def types_array
    @types
  end

  # Should measurements be fetched using one thread
  def one_thread
    true == @config[:one_thread]
  end

  # Interval used for one thread measurement fetching
  def one_thread_interval
    if @config[:one_thread_interval].to_f >= MIN_ONE_THREAD_INTERVAL
      return @config[:one_thread_interval]
    else
      return MIN_ONE_THREAD_INTERVAL
    end
  end

  # Start measurement fetching threads
  def start
    # if started block running
    return if running
    @running = true

    if false == one_thread
      # normal threaded
      types_array.each do |mt|
        mt.start
      end
    else
      # one thread
      start_one_thread
    end
  end

  # Stop measurement fetching threads
  def stop
    if false == one_thread
      # normal threaded
      types_array.each do |mt|
        mt.stop
      end
    else
      # one thread
      stop_one_thread
    end
    @running = false
  end

  private

  # Create fetching thread for all types
  def start_one_thread
    @rt_one_thread = StartThreaded.start_threaded_precised(one_thread_interval, 0.1, self) do
      @types.each do |mt|
        # mt is MeasurementType
        mt.single_fetch
      end
    end
  end

  # Stop thread of "1-thread measurement fetching" used on slow PCs
  def stop_one_thread
    @rt_one_thread.thread.kill
  end

  # Create AR objects and MeasurementType instances
  def initialize_type
    @config[:array].each do |m_def|
      # initialize AR object
      mt = MeasType.find_or_create_by_name(m_def[:name])
      m_def[:meas_type_id] = mt.id

      # initialize MeasurementType object
      @types << MeasurementType.new(m_def)
    end
  end

end