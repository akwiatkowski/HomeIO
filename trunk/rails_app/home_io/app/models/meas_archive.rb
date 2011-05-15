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


# Measurements

class MeasArchive < ActiveRecord::Base
  belongs_to :meas_type

  validates_presence_of :value, :time_from, :time_to, :meas_type

  # will paginate
  attr_reader :per_page
  @per_page = 20

  # recent measurements
  scope :recent, :order => "time_from DESC", :include => :meas_type


  # Measurement time range begin. Fix for storing microseconds
  def time_from_w_ms
    return Time.at(self.time_from.to_i.to_f + self._time_from_ms.to_f / 1000.0)
  end

  # Measurement time range end. Fix for storing microseconds
  def time_to_w_ms
    return Time.at(self.time_to.to_i.to_f + self._time_to_ms.to_f / 1000.0)
  end

  # Measurement time range begin. Fix for storing microseconds
  def time_from_w_ms=(t)
    self.time_from = t
    self._time_from_ms = t.usec / 1000
  end

  # Measurement time range end. Fix for storing microseconds
  def time_to_w_ms=(t)
    self.time_to = t
    self._time_to_ms = t.usec / 1000
  end

  # Create json data used for creating charts for MeasArchive instances
  # TODO move it elsewhere
  def self.to_json_graph(array)
    times = Array.new
    values = Array.new

    #times = @meas_archives.collect{|w| ( (w.time_from - Time.now) + (w.time_from - Time.now) ) / ( 2 * 60 ) }
    #values = @meas_archives.collect{|w| w.value }

    array.sort { |m, n| m.time_from <=> n.time_from }.each do |ma|
      # measurements will be drawn as horizontal line as time range
      times << (ma.time_from - Time.now) / 60
      times << (ma.time_to - Time.now) / 60


      values << ma.value
      values << ma.value
    end

    return {
      :x => times,
      :y => values
    }
  end

end
