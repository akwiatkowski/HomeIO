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
#    along with HomeIO.  If not, see <http://www.gnu.org/licenses/>.


require 'singleton'
require 'lib/metar_logger'
require 'lib/utils/geolocation'
require 'lib/storage/storage_active_record'
require 'lib/storage/active_record/backend_models/city'

# Generate dynamic IDs for cities used by weather providers using geo. coordinates

class WeatherCityProxy
  include Singleton

  # Last free id for city
  attr_reader :last_city_id

  # Verbose mode
  attr_accessor :verbose
  # Log warning when city with other name is near another city
  # and they are joined
  attr_accessor :log_different_city_names

  # When all cities was processed it is set to true
  attr_reader :fixed

  # when we have to create another city with the same name we use suffix
  NAME_SUFFIX_WHEN_NEEDED = '#'

  # location within this distance is threated like the same city [km]
  CITY_DISTANCE_TOLERANCE = 15

  # Deadlock safe initialization 
  def initialize
    @last_city_id             = 1
    @verbose                  = true
    @log_different_city_names = true
  end

# Process and set ids if needed
  def post_init
    if not true == @fixed
      # initialize active record
      StorageActiveRecord.instance
      # add all used city hashes here and process them later
      @cities = Array.new

      # fetch cities which has already id
      fetch_cities_from_db
      # attach cities from other components which use location
      attach_metar
      attach_weather
      # process
      fix_ids
    end
    @fixed = true
  end

  # Fetch cities from DB to check which has ids already
  def fetch_cities_from_db
    @db_cities = Cities.all
    @db_cities.each do |c|
      id_was_used(c.id)
    end
  end

  # Attach metar cities
  def attach_metar
    @metar_cities = MetarLogger.instance.cities
    @metar_cities.each do |c|
      @cities << c
    end
  end

  # Attach weather ripper cities
  def attach_weather
    @weather_cities = Hash.new
    WeatherRipper.instance.providers.each do |obj|
      k     = obj.class.to_s.to_sym
      # weather provider cities (hashes)
      wr_cs = obj.defs

      # add all cities to local pool
      wr_cs.each do |c|
        @cities << c
      end
    end
  end

  # Check all cities and get id if needed (and create record in DB) 
  def fix_ids
    @cities.each do |c|
      # if city has no id
      if c[:id].nil?
        # search for that city in base
        search_id_result = search_db_cities_for_id(c)

        if search_id_result.nil?
          # create city in DB
          new_city = City.create!({
                                      :name    => c[:city],
                                      :country => c[:country],
                                      :lat     => c[:coord][:lat],
                                      :lon     => c[:coord][:lon]
                                  })
          new_city.save!
          c[:id] = new_city.id
        end
      end
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
      if (mc[:name] == c[:city]) or (dist < CITY_DISTANCE_TOLERANCE and not c[:near_other_city] == true)
        city_hash[:id] = c.id
        return city_hash
      end
    end
    # could not find anything
    return nil
  end


  # TODO
  # after initialization fetch from DB, from mtera, weather
  # got to last possible id using id_was_used( id )
  # create 2 array, cities not processed, and to process
  # check all unprocessed if there is already same city (in db or just processed)
  # 'same' - and use distance condition
  # if it is use it id
  # if not, create id and create record in DB for future use
  # ! this method should be used at start metar or weather or other future citybased part of homeio

  # Process and set ids if needed
  def DEL_post_init
    if not true == @fixe
      # fetch cities which has already id
      fetch_cities_from_db
      # attach cities from other components which use location
      attach_metar
      attach_weather
      # process
      fix_ids
    end
    @fixed = true
  end


  # Return unified cities array
  def cities_array
    post_init

    a = Array.new
    @metar_cities.each do |m|
      a << {
          :id      => m[:id],
          :country => m[:country],
          :name    => m[:name],
          :metar   => m[:code],
          :lat     => m[:coord][:lat],
          :lon     => m[:coord][:lon]
      }
    end

    @weather_cities.keys.each do |k|
      @weather_cities[k].each do |c|
        a << {
            :id      => c[:id],
            :country => c[:country],
            :name    => c[:city],
            :lat     => c[:coord][:lat],
            :lon     => c[:coord][:lon]
        }
      end
    end

    return a.uniq.sort { |a, b| a[:id] <=> b[:id] }
  end

  private

  # Fix ids using id from DB
  def fix_ids
    #@db_cities

    @metar_cities.each do |mc|
      if mc[:id].nil?
        # city used for metar logging does not have id
        # select city with exact metar code
        #c_exact_metar = @db_cities.select { |c| c.metar == }

        mc[:id] = db_cities
      end
    end
  end

  def OLD_fix_weather_cities_definition(k)
    # search for city with similar name or nearly distance
    @weather_cities[k].each do |c|
      fix_weather_city(c)
    end
  end

  def OLD_fix_weather_city(c)
    # checking on metars
    @metar_cities.each do |mc|
      # matching names or distance
      dist = Geolocation.distance_2points(c[:coord][:lat], c[:coord][:lon], mc[:coord][:lat], mc[:coord][:lon])
      if (mc[:name] == c[:city]) or (dist < CITY_DISTANCE_TOLERANCE and not c[:near_other_city] == true)
        # city exist
        if not mc[:name] == c[:city] and @log_different_city_names
          AdvLog.instance.logger(self).warning("Cities merged #{mc[:name]} has #{c[:city]}")
        end

        c[:id] = mc[:id]
        id_was_used(mc[:id])
        puts "reusing id from metar #{mc[:id]}, #{mc[:name]} == #{c[:city]}" if @verbose
        return c
      end
    end

    # checking on weather's providers
    @weather_cities.keys.each do |key|
      wp = @weather_cities[key]
      # checking on weather's cities
      wp.each do |wc|
        # *wc* need to has id already
        if not wc[:id].nil?

          # matching names or distance
          dist = Geolocation.distance_2points(c[:coord][:lat], c[:coord][:lon], wc[:coord][:lat], wc[:coord][:lon])
          if ((wc[:city] == c[:city]) or (dist < CITY_DISTANCE_TOLERANCE))
            # city exist
            if not wc[:city] == c[:city] and @log_different_city_names
              AdvLog.instance.logger(self).warning("Cities merged #{wc[:name]} has #{c[:city]}")
            end

            c[:id] = wc[:id]
            id_was_used(wc[:id])
            puts "reusing id from weather #{wc[:id]}, #{wc[:city]} == #{c[:city]}" if @verbose
            return
          end

        end
      end
    end

    # city without id - using a new one
    c[:id] = @last_city_id
    id_was_used(@last_city_id)
    puts "new id #{c[:id]}, #{c[:city]}" if @verbose
    return c
  end


  # Usable ID will be larger than any ID uses so far
  def id_was_used(id)
    if @last_city_id <= id
      @last_city_id = id + 1
    end
  end

end
