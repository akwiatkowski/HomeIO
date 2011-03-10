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

require "lib/utils/start_threaded"
require 'lib/communication/io_comm/io_protocol'
require 'lib/storage/storage_active_record'

# One type o measurement. Start threaded fetching measurement data from IoServer.

class MeasurementType

  # Measurement can be fetched every product of this seconds
  BASIC_INTERVAL = 0.1

  # Create new MeasurementType using Hash from
  def initialize(config_hash)
    @config = config_hash
    @measurements = Array.new

    # count of stored measurement of this type
    @stored_count = 0
    # Are measurements added to pool and stored when the pool is full. If not they are stored now.
    @use_storage_pool = (true == @config[:log_conditions][:offline])

    # initialize AR connection
    StorageActiveRecord.instance
  end

  # Create Hash with all important parameters of that object, with last value
  def to_hash
    h = {
      :type => type,
      :value => value,
      :time => time_to,
      :time_to => time_to,
      :raw => raw,
      :locale => locale
    }
    h
  end

  # Interval every measurement in interval units. Can not be lower than 1.
  def interval
    i = @config[:command][:frequency].to_i
    return i if i < 1
    return i
  end

  # Interval every measurement in interval seconds
  def interval_seconds
    self.interval.to_f * BASIC_INTERVAL
  end

  # Count of stored measurements
  def stored_count
    @stored_count
  end

  # Stop measurement fetching loop
  def stop
    return if @rt.nil?
    @rt.thread.kill
    @rt = nil
  end

  def type
    @config[:type]
  end

  def unit
    @config[:unit]
  end

  # Array sent to uC
  def command_array
    @config[:command][:array]
  end

  # Number of bytes of uC response
  def response_size
    @config[:command][:response_size]
  end

  def coefficient_linear
    @config[:command][:coefficient_linear]
  end

  def coefficient_offset
    @config[:command][:coefficient_offset]
  end

  # Foreign key for storing in DB using AR
  def meas_type_id
    @config[:meas_type_id]
  end

  # Value of last measurement
  def value
    @measurements.last[:value]
  end

  # Value used for storing
  def value_to_store
    @measurement_after_last_store[:value]
  end

  # Raw of last measurement
  def raw
    @measurements.last[:raw]
  end

  def locale
    @config[:locale]
  end

  # Raw value used for storing
  def raw_to_store
    @measurement_after_last_store[:raw]
  end

  def time_to
    @measurements.last[:time]
  end

  def time_from
    @measurement_after_last_store[:time]
  end

  def time_interval
    time_to - time_from
  end

  # Start (or allow_restart) measurement fetching loop
  def start(allow_restart = false)
    # force restart
    if not @rt.nil? and true == allow_restart
      stop
    end
    # start when thread is not started
    start_threaded if @rt.nil?
  end

  private

  # Start threaded loop
  def start_threaded
    # initial measurement fetch, without actual storing
    fetch_measurement
    mark_current_measurement_as_stored

    @rt = StartThreaded.start_threaded_precised(interval_seconds, 0.001, self) do
      fetch_measurement
      # store when conditions are met
      if check_storage_conditions
        store_measurement_in_db
      end

      puts "meas  #{self.type.to_s.ljust(20)} #{self.value_to_store.to_s.ljust(20)} #{self.unit.to_s.ljust(20)} #{@stored_count.to_s.rjust(20)} stored #{self.raw_to_store.to_s.ljust(20)}"
      #puts @measurement_after_last_store.inspect
      #puts @measurements.last.inspect
      #puts @measurements.size
      #puts @stored_count
      #puts ""
    end
  end

  # Fetch measurement using IoProtocol (tcp protocol to IoServer) and add to cache
  def fetch_measurement
    io_result = IoProtocol.instance.fetch(command_array, response_size)
    raw = IoProtocol.string_to_number(io_result)
    value = process_raw_to_real(raw)
    add_measurement_to_cache(raw, value)
  end

  # Add one measurement to cache
  def add_measurement_to_cache(raw, value)
    h = {
      :time => Time.now,
      :value => value,
      :raw => raw
    }
    @measurements << h

    # shift first elements from array to maintain max cache size
    while @measurements.size > max_cache_size
      @measurements.shift
    end
  end

  # Process raw to real value
  def process_raw_to_real(raw)
    raw * coefficient_linear + coefficient_offset
  end

  # Max size of cache array
  def max_cache_size
    @config[:cache]
  end

  # Check storage conditions. When true current measurement should be stored
  def check_storage_conditions
    # do not store if measurement is fresh
    return false if true == check_minimal_time_interval

    # force store if measurement is a little old now
    return true if true == check_maximum_time_interval

    # not it depends only on value
    check_significant_change
  end

  def minimal_time_interval
    @config[:log_conditions][:min].to_f
  end

  # Return true if current measurement is freshly after stored one
  def check_minimal_time_interval
    time_interval < minimal_time_interval
  end

  def maximum_time_interval
    @config[:log_conditions][:max].to_f
  end

  # Return true if current measurement is a little old one
  def check_maximum_time_interval
    time_interval > maximum_time_interval
  end

  # Amount of value which enforce storage
  def significant_change
    @config[:log_conditions][:sig_change].to_f
  end

  # Return true if current value is a little old one
  def check_significant_change
    (value - value_to_store).abs >= significant_change
  end

  # Are measurements added to pool and stored when the pool is full. If not they are stored now.
  def use_storage_pool
    @use_storage_pool
  end

  # TODO clean it a little, add writing meas. to csv file
  def store_measurement_in_db
    ma = MeasArchive.new(
      {
        :meas_type_id => meas_type_id,
        :raw => raw_to_store,
        :value => value_to_store,
        :time_from_w_ms => time_from,
        :time_to_w_ms => time_to
      }
    )

    @stored_count += 1

    if use_storage_pool
      StorageActiveRecord.instance.store_ar_object(ma)
    else
      ma.save!
    end

    mark_current_measurement_as_stored
  end

  # Mark current measurement that was last stored
  def mark_current_measurement_as_stored
    @measurement_after_last_store = @measurements.last
  end


end