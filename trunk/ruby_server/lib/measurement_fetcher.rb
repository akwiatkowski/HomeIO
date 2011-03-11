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

# Singleton for fetching and storing measurements
class MeasurementFetcher
  include Singleton

  # Cities definition array
  attr_reader :meas_array

  # Get cities list for fetching
  def initialize
    @config = ConfigLoader.instance.config(self.class.to_s)
    # return if enabled = false
    return unless @config[:enabled]

    @meas_array = MeasurementArray.instance
    @meas_array.start
  end

  # Get last measurements in array format. Usable by bots and
  # TODO create hash in MT object
  def get_last
    @meas_array.types_array.collect { |m|
      m.to_hash
    }
  end

  def get_value(type)
    @meas_array.types_array.each do |m|
      if m.type == type
        return m.to_hash
      end
    end
  end

end