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
require 'lib/utils/config_loader'
require 'lib/measurements/measurement_array'

# Singleton for fetching and storing measurements. One of main feature of HomeIO.

class MeasurementFetcher
  include Singleton

  # measurements
  attr_reader :meas_array

  # Load config and start threads if enabled
  def initialize
    @config = ConfigLoader.instance.config(self.class.to_s)
    # return if enabled = false
    return unless @config[:enabled]

    @meas_array = MeasurementArray.instance
    @meas_array.start
  end

  # Get last measurements in array of hashes format. Usable for bots.
  def get_last_hash
    @meas_array.types_array.collect { |m|
      m.to_hash
    }
  end

  # Get last measurements in hash format. Usable for bots.
  def get_hash_by_name(name)
    @meas_array.types_array.each do |m|
      if m.name == name
        return m.to_hash
      end
    end
    # when not found return nil
    nil
  end

  # Get last measurements
  def get_meas_type_by_name(name)
    @meas_array.types_array.each do |m|
      if m.name == name
        return m
      end
    end
    # when not found return nil
    nil
  end

  # Get last measured value (only value, without time, and other parameters) for type
  def get_value_by_name(name)
    hash = get_hash_by_name(name)
    return hash[:value] unless hash.nil?
  end

end