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


# Cities

class City < ActiveRecord::Base
  has_many :weather_metar_archives
  has_many :weather_archives

  validates_presence_of :country, :name, :lat, :lon
  validates_uniqueness_of :name, :scope => [:lat, :lon]
  validates_uniqueness_of :name, :scope => [:country]
  validates_uniqueness_of :metar, :allow_nil => true

  default_scope :order => :calculated_distance

  # will paginate
  cattr_reader :per_page
  @@per_page = 20

  # Update flags used for not searching entire table for data which is not available
  def update_search_flags
    puts "Updating search flag for city ID #{self.id} - #{self.name}"
    if WeatherArchive.find(:all, :conditions => { :city_id => self.id }, :limit => 1).size > 0
      update_attribute(:logged_weather, true)
    else
      update_attribute(:logged_weather, false)
    end

    if WeatherMetarArchive.find(:all, :conditions => { :city_id => self.id }, :limit => 1).size > 0
      update_attribute(:logged_metar, true)
    else
      update_attribute(:logged_metar, false)
    end
    puts "...done"
  end

  # Update flags for all cities
  def self.update_search_flags_for_all_cities
    City.all.each do |c|
      c.update_search_flags
    end
  end

  def self.get_all_weather
    #cities = self.order(:calculated_distance).limit(10).all
    cities = self.order(:calculated_distance).all
    weather = Array.new

    cities.each do |c|
      weather += c.last_weather(1)
    end

    return weather
  end

  # Get last weather records
  def last_weather(count = 1)
    if self.logged_metar
      # use metar
      return self.weather_metar_archives.order('time_from DESC').limit(count).all
    elsif self.logged_weather
      # use weather
      return self.weather_archives.order('time_from DESC').limit(count).all
    else
      # nothing
      return []
    end
  end

end
