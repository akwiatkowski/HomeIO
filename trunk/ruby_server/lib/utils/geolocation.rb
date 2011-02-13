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


require 'rubygems'
require 'geokit'
require 'lib/utils/config_loader'

# Proxy for geokit gem using predefined location

class Geolocation
  # Default options for geokit: unit km and using sphere formula for distance calculation
  DEFAULT_OPTIONS = {
      :units   => :kms,
      :formula => :sphere
  }

  # Create new location
  #
  # :call-seq:
  #   new( Float lat, Float lot ) => Geolocation for coordinates
  #   new => Geolocation for installation site
  def initialize(lat = nil, lon = nil)
    @config = ConfigLoader.instance.config(self.class)
    @_lat   = lat.nil? ? @config[:site][:lat] : lat
    @_lon   = lon.nil? ? @config[:site][:lon] : lon
    @geo    = Geokit::LatLng.new(@_lat, @_lon)
  end

  # Accessor for latitude
  def lat
    @geo.lat
  end

  # Accessor for longitude
  def lon
    @geo.lng
  end

  # Accessor for longitude
  def lng
    @ge.lng
  end

  # Calculate distance in km from installation site
  #
  # :call-seq:
  #   Geolocation.distance( Float lat, Float lot ) => distance from site
  def self.distance(new_lat, new_lon)
    config      = ConfigLoader.instance.config(self.new.class.to_s)
    geo         = Geokit::LatLng.new(config[:site][:lat], config[:site][:lon])
    other_point = Geokit::LatLng.new(new_lat, new_lon)
    return geo.distance_to(other_point, DEFAULT_OPTIONS)
  end

  # Calculate distance in km from installation site
  #
  # :call-seq:
  #   distance( Float lat, Float lot ) => distance from site
  #   distance => distance from site to site, yeah, it's funny
  def distance(new_lat = lat, new_lon = lon)
    @other_point = Geokit::LatLng.new(new_lat, new_lon)
    return @geo.distance_to(@other_point, DEFAULT_OPTIONS)
  end

  # Calculate distance in km between 2 points
  # :call-seq:
  #   distance( Float lat, Float lot, Float lat, Float lot  ) => distance between 2 points
  def self.distance_2points(lat_from, lon_from, lat_to, lon_to)
    geo         = Geokit::LatLng.new(lat_from, lon_from)
    other_point = Geokit::LatLng.new(lat_to, lon_to)
    return geo.distance_to(other_point, DEFAULT_OPTIONS)
  end

end
