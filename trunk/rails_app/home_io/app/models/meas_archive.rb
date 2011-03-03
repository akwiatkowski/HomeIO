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

  # Measurement time range begin. Fix for storing microseconds
  def time_from
    return Time.at( self._time_from.to_i + self._time_from_us.to_i )
  end

  # Measurement time range end. Fix for storing microseconds
  def time_to
    return Time.at( self._time_to.to_i + self._time_to_us.to_i )
  end

  # Measurement time range begin. Fix for storing microseconds
  def time_from=(t)
    self._time_from = t
    self._time_from_us = t.usec
  end

  # Measurement time range end. Fix for storing microseconds
  def time_to=(t)
    self._time_to = t
    self._time_to_us = t.usec
  end

end
