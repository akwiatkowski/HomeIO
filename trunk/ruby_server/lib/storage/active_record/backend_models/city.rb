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


require File.join Dir.pwd, 'lib/storage/active_record/rails_models/city'
require 'yaml'

# Cities

class City

  # Create or update cities
  def self.create_or_update(h)
    c = City.find(:first, :conditions => {:id => h[:id]})

    if c.nil?
      puts "not found city #{h[:id]} - #{h[:name]}"
      res = City.new(h).safe_save
      return res
    else
      # use hash to update attributes without removing old
      c.update_attributes(c.attributes.merge(h))
    end

  end

  # Save method which log errors into HomeIO logs
  def safe_save
    begin
      self.save!
    rescue => e
      puts "error"
      puts e.inspect
      puts self.inspect
      #puts City.find( self.id ).name
      log_error(self, e, self.inspect)
    end
    return self
  end

  # verbose mode, for development
  VERBOSE = true

  # Calculate distance for a city
  def recalculate_distance
    self.calculated_distance = Geolocation.distance(self.lat, self.lon)
  end

  before_save :recalculate_distance

end
