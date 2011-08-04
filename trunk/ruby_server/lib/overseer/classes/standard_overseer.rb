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
require 'lib/overseer/overseer_manager'
require 'lib/action/action_manager'
require 'lib/utils/start_threaded'

# Simple class used to control system. Check one type of measurement and perform actions when value drops below or
# exceeds sat value

class StandardOverseer

  # show some information
  VERBOSE = true

  # show this before putting overseers information
  VERBOSE_PREFIX = "OVSR - "

  # Was conditions met last time. State is set when action was successfully executed.
  attr_reader :state

  # needed parameters
  #  :measurement_name - name/type of measurement which is checked
  #  :greater - true/false, true - check if value is greater
  #  :threshold_value - value which is compared to
  #  :threshold_proc - proc modifying threshold value, should be nil or return Float, used without parameters
  #  :action_name - action name/type to execute if check is true
  #  :interval - interval of checking condition
  #  :re_execute - default false - execute action only when conditions are met

  # Create StandardOverseer
  def initialize(params)
    # this type does not need it
    # @extractor = ExtractorActiveRecord.instance
    @measurement_fetcher = MeasurementFetcher.instance
    @measurement_array = @measurement_fetcher.meas_array
    @action_manager = ActionManager.instance

    @params = params
    raise 'Params for overseer must be a Hash object' unless @params.kind_of?(Hash)

    # previous state
    @state = false

    # statistics
    @stats = Hash.new
    @stats[:state] = @state

    # active by default
    @params[:active] = true if @params[:active].nil?

    # register in OverseerManager
    OverseerManager.instance.register_overseer(self)

    # TODO actions with reexecution
  end

  # Start Overseer thread
  def start
    unless valid?
      raise 'Overseer is not valid'
      return false
    end

    # when was started
    @stats[:start_time] = Time.now

    puts "#{VERBOSE_PREFIX}#{self.class} started - #{@params.inspect}" if VERBOSE
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

  # Set id using Overseer (ActiveRecord)
  def set_overseer_id(ar_overseer)
    # TODO try to find_by_name if not set
    if ar_overseer.kind_of? Overseer
      @overseer_id = ar_overseer.id
    else
      raise "Tried to set id of Overseer using wrong object"
    end
  end

  # Some useful accessors

  # Parameters and statistics output
  def to_hash
    p = @params.clone
    p[:stats] = @stats
    p[:stats][:current_threshold_value] = self.threshold_value
    p[:overseer_id] = @overseer_id
    p
  end

  # Parameters and statistics output
  def params
    @params.clone
  end

  def name
    @params[:name] || "Unknown #{self.object_id}"
  end

  alias_method :overseer_name, :name

  # Is overseer active
  def active
    # TODO add active flag
    #@params[:active]
    true
  end

  # Name of measurement used for this Overseer (String)
  def measurement_name
    @params[:measurement_name]
  end

  # Type of measurement used for this Overseer (MeasurementType)
  def measurement
    @measurement_fetcher.get_meas_type_by_name(measurement_name)
  end

  # Name of action used for this Overseer (String)
  def action_name
    @params[:action_name]
  end

  # Type of action used for this Overseer (Action)
  def action
    @action_manager.get_by_name(action_name)
  end

  # Type of action used for this Overseer (Action)
  def action_type
    action
  end

  # Threshold value with modification
  def threshold_value
    tv = @params[:threshold_value]
    tv += @params[:threshold_proc].call unless @params[:threshold_proc].nil?
    tv
  end

  # If false execute actions only when conditions are met for the first time
  def re_execute
    if @params[:re_execute]
      true
    else
      false
    end
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
      puts "Error #{VERBOSE_PREFIX}Measurement type is not available for #{self.inspect}"
      return false
    end

    # action
    if action.nil?
      puts "Error #{VERBOSE_PREFIX}Action type is not available for #{self.inspect}"
      return false
    end

    # threshold value
    if threshold_value.nil?
      puts "Error #{VERBOSE_PREFIX}Threshold value is not set #{self.inspect}"
      return false
    end

    # interval
    if interval.nil?
      puts "Error #{VERBOSE_PREFIX}Interval is not set #{self.inspect}"
      return false
    end

    return true
  end

  private

  # Execute action if conditions are met
  def loop_method
    # condition check status
    check_status = check

    if re_execute == false
      # execute only when status was false and conditions were met
      execute_action if state == false and check_status == true

      # when conditions are not met set state = false
      @state = false if check_status == false

      # when state == false and check_status == true - do nothing

    else
      # execute when conditions are met
      execute_action if check_status

    end

  end

  # Check if conditions are met
  def check
    puts "#{VERBOSE_PREFIX}#{self.class} check condition - #{measurement.value} <> #{threshold_value}, gr = #{greater}" if VERBOSE

    # last checked value
    @stats[:last_checked_value] = measurement.value

    if greater
      # has to be greater
      if measurement.value > threshold_value
        # condition met
        return true
      end

    else
      # has to be smaller
      if measurement.value < threshold_value
        # condition met
        return true
      end

    end

    false
  end

  # Execute action when condition is met, and change state.
  def execute_action
    # statistics
    @stats[:last_hit] = Time.now
    @stats[:hit_count] = @stats[:hit_count].to_i + 1
    @stats[:state] = @state

    puts "#{VERBOSE_PREFIX}#{self.class} execute action - #{@params.inspect}, action #{action_name}" if VERBOSE
    # old, not storing overseer id
    #@state = action.execute
    # new, using overseer id
    @state = action.execute(nil, @overseer_id)

    puts "#{VERBOSE_PREFIX}#{self.class} state after #{state}"
  end


end