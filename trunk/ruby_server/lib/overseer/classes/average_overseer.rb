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

require 'lib/overseer/classes/standard_overseer'

# A little less simple class used to control system. Check one type of measurement and perform actions when average value
# drops below or exceeds condition value.

class AverageOverseer < StandardOverseer

  # needed parameters
  #  :measurement_name - type of measurement which is checked
  #  :greater - true/false, true - check if value is greater
  #  :threshold_value - value which is compared to
  #  :action_name - action type to execute if check is true
  #  :interval - interval of checking condition
  #  :average_count - number of measurements used to calculate average

  # Create StandardOverseer
  #def initialize(params)
  #  super(params)
  #end

  # How many measurements needed for average value
  def average_count
    @params[:average_count]
  end

  # Average value. Is nil when not enough measurements.
  def average_value
    measurement.average_value(average_count)
  end

  # Check if this Overseer is valid and can be started
  def valid?
    # measurement type must be available
    if average_count.nil?
      puts "Error #{VERBOSE_PREFIX}Average count is not set"
      return false
    end

    super
  end

  private

  # Check if conditions are met
  def check
    if VERBOSE
      greater ? gr_sym = ">" : gr_sym = "<"

      _current_value = average_value
      _current_value = "NULL" if _current_value.nil?

      puts "#{VERBOSE_PREFIX}#{self.class} check condition - value #{gr_sym} threshold"
      puts "#{VERBOSE_PREFIX}#{self.class} check condition - #{_current_value} #{gr_sym} #{threshold_value.to_s}"
    end

    av = average_value

    # last checked value
    @stats[:last_checked_value] = av

    # when not enough measurements
    if av.nil?
      return false
    end

    if greater
      # average has to be greater
      if average_value > threshold_value
        # condition met
        return true
      end

    else
      # average has to be smaller
      if average_value < threshold_value
        # condition met
        return true
      end

    end

    false
  end

end