#!/usr/bin/ruby
#encoding: utf-8

# This file is part of HomeIO.
#
#    HomeIO is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    HomeIO is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.


# Cities

class City < ActiveRecord::Base
  has_many :weather_metar_archives
  has_many :weather_archives

  validates_presence_of :country, :name, :lat, :lon

  # verbose mode, for development
  VERBOSE = true

  # Calculate distance for a city
  def recalculate_distance
    self.calculated_distance = Geolocation.distance( self.lat , self.lon )
  end

  before_save :recalculate_distance

end
