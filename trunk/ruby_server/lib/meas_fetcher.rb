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

# Singleton for fetching and storing measurements
class MeasFetcher
  include Singleton

  # Cities definition array
  attr_reader :meas_array

  # Get cities list for fetching
  def initialize
    @cities = ConfigLoader.instance.config(self.class.to_s)[:cities]
    puts "#{self.class.to_s} init - #{@cities.size} cities"
  end

end