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

# One type o measurement. Start threaded fetching measurement data from IoServer.

class MeasurementType

  # Measurement can be fetched every product of this seconds
  BASIC_INTERVAL = 0.1

  # Create new MeasurementType using Hash from
  def initialize(config_hash)
    @config = config_hash
    @measurements = Array.new
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

  # Stop measurement fetching loop
  def stop
    return if @rt.nil?
    @rt.thread.kill
    @rt = nil
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
    fetch_measurement
    @rt = StartThreaded.start_threaded_precised(interval_seconds, 0.001, self) do
      fetch_measurement
    end
  end

  # Fetch measurement using IoProtocol (tcp protocol to IoServer)
  def fetch_measurement
    io_result = IoProtocol.instance.fetch(command_array, response_size)
    raw = IoProtocol.array_to_number(io_result)
    value = process_raw_to_real(raw)
    add_measurement_to_internal_array(raw, value)
  end

  def add_measurement_to_internal_array(raw, value)
    h = {
      :time => Time.now,
      :value => value,
      :raw => raw
    }
    @measurements << h
    puts h.inspect
  end

  # Process
  def process_raw_to_real(raw)
    raw * coefficient_linear + coefficient_offset
  end


end