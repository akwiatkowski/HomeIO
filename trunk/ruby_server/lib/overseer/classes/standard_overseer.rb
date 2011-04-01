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

require 'lib/communication/db/extractor_active_record'
require 'lib/measurements/measurement_fetcher'
require 'lib/action/action_manager'
require 'lib/utils/start_threaded'

# Simple class used to control system. Check one type of measurement and perform actions when value drops below or
# exceeds sat value

class StandardOverseer

  # needed parameters
  #  :measurement_type - type of measurement which is checked
  #  :greater - true/false, true - check if value is greater
  #  :threshold_value - value which is compared to
  #  :action_type - action type to execute if check is true

  # Create StandardOverseer
  def initialize(params)
    # this type does not need it
    # @extractor = ExtractorActiveRecord.instance
    @measurement_fetcher = MeasurementFetcher.instance
    @measurement_array = @measurement_fetcher.meas_array
    @action_manager = ActionManager.instance

    @params = params
    raise 'Params for overseer must be a Hash object' unless @params.kind_of?(Hash)

    # TODO create migration for overseers, list of overseers and parameters (like hash) for them
  end

  # Start Overseer thread
  def start
    unless valid?
      raise 'Overseer is not valid'
      return false
    end

    @rt = StartThreaded.start_threaded(interval, self) do
      # check and execute action if needed
      loop_method
    end
  end

  # Stop Overseer thread
  def stop
    return false if @rt.nil?

    @rt.thread.kill
    return true
  end

  # Some useful accessors

  # Type of measurement used for this Overseer (String)
  def measurement_type
    @params[:measurement_type]
  end

  # Type of measurement used for this Overseer (MeasurementType)
  def measurement
    @measurement_fetcher.get_by_type(measurement_type)
  end

  # Type of action used for this Overseer (String)
  def action_type
    @params[:action_type]
  end

  # Type of action used for this Overseer (Action)
  def action
    @action_manager.get_by_type(action_type)
  end

  # Threshold value
  def threshold_value
    @params[:threshold_value]
  end

  # Type of checks, check if current value is greater if this is true
  def greater
    if @params[:greater]
      true
    else
      false
    end
  end

  # Check every this amount of seconds
  def interval
    @params[:interval]
  end


  # Check if this Overseer is valid and can be started
  def valid?
    # measurement type must be available
    if measurement.nil?
      puts "Measurement type is not available for #{self.inspect}"
      return false
    end

    # action
    if action.nil?
      puts "Action type is not available for #{self.inspect}"
      return false
    end

    # threshold value
    if threshold_value.nil?
      puts "Threshold value is not set #{self.inspect}"
      return false
    end

    # interval
    if interval.nil?
      puts "Interval is not set #{self.inspect}"
      return false
    end

    return true
  end

  private

  # Execute action if conditions are met
  def loop_method
    execute_action if check
  end

  def check

  end

  def execute_action

  end


end