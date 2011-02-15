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
require 'lib/metar_logger'
require 'lib/utils/geolocation'
require 'lib/storage/storage_active_record'
require 'lib/storage/active_record/backend_models/city'

# Proxy class for recreating cities in DB

class CityProxy
  include Singleton

  # When all cities was processed it is set to true
  attr_reader :fixed

  # Verbose mode
  attr_accessor :verbose

  # location within this distance is threaten like the same city [km]
  CITY_DISTANCE_TOLERANCE = 15

  # Deadlock safe initialization
  def initialize
    @verbose = true
    @fixed = false
    @cities = Array.new
  end

  # Run fix after initialization
  def post_init
    if not true == @fixed
      id_fix
      @fixed = true
    end
  end

  # Return unified cities array (Array of Hashes {:id, :country, :name, ...}
  def cities_array
    post_init

    a = Array.new
    @cities.each do |c|
      a << {
        :id => c[:id],
        :country => c[:country],
        :name => c[:name],
        :city => c[:city],
        :metar => c[:code],
        :lat => c[:coord][:lat],
        :lon => c[:coord][:lon]
      }
    end

    return a.uniq.sort { |a, b| a[:id] <=> b[:id] }
  end

  # Get city information by metar code
  #
  # :call-seq:
  #   find_city_by_metar( String metar code ) => Hash
  def find_city_by_metar(metar_code)
    post_init
    @cities.select { |c| metar == c[:metar] }.first
  end

  private

  # Fetch cities from DB to check which has ids already
  def id_fix
    # fetch from db
    StorageActiveRecord.instance
    @db_cities = City.all

    @cities = Array.new

    # fetch from metar
    @metar_cities = MetarLogger.instance.cities
    @metar_cities.each do |c|
      @cities << c
    end

    # Fetch from weather ripper
    @weather_cities = Hash.new
    WeatherRipper.instance.providers.each do |obj|
      # weather provider cities (hashes)
      wr_cs = obj.defs
      # add all cities to local pool
      wr_cs.each do |c|
        @cities << c
      end
    end

    # Check if this city is in DB, when not create it
    @cities.each do |c|
      search_id_result = search_db_cities_for_id(c)
      if search_id_result.nil?
        # create city in DB
        h = {
          :name => c[:city],
          :country => c[:country],
          :metar => c[:code],
          :lat => c[:coord][:lat],
          :lon => c[:coord][:lon],
          :calculated_distance => Geolocation.distance(c[:coord][:lat], c[:coord][:lon])
        }
        puts c.inspect
        new_city = City.new(h)

        if not new_city.valid?
          AdvLog.instance.logger(self).error("City can not be created #{new_city.inspect}")
          AdvLog.instance.logger(self).error("City can not be created #{new_city.errors.inspect}")
          puts "City can not be created #{new_city.inspect}"
        else
          puts "Creating city #{new_city.name}"
        end

        new_city.save!
        c[:id] = new_city.id

        # add to cities from db - it is now i db
        @db_cities << new_city
      else
        # update some attributes only
        # find in DB
        city_to_update = City.find(search_id_result[:id])
        # update metar when it is needed
        city_to_update.update_attribute(:metar, search_id_result[:metar]) unless search_id_result[:metar].nil?
        # place to add other updates like :calculated_distance
      end
      # compatibility issue
      c[:name] = c[:city]
      c[:metar] = c[:code]
    end
  end

  # Find identical city from cities fetched from DB and use it id
  #
  # :call-seq:
  #   search_db_cities_for_id( city Hash from definitions ) => nil if not found
  #   search_db_cities_for_id( city Hash from definitions ) => Hash with id
  def search_db_cities_for_id(city_hash)
    @db_cities.each do |c|
      # distance city without id to city from DB
      dist = Geolocation.distance_2points(c.lat, c.lon, city_hash[:coord][:lat], city_hash[:coord][:lon])
      if (c.name == c[:city]) or (dist < CITY_DISTANCE_TOLERANCE and not c[:near_other_city] == true)
        city_hash[:id] = c.id
        return city_hash
      end
    end
    # could not find anything
    return nil
  end

end