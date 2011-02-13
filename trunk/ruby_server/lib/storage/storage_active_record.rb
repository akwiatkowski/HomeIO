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


# TODO mutex when adding to pool

require 'lib/storage/storage_db_abstract'
require 'rubygems'
require 'active_record'
require 'singleton'

# better way to load all models from dir, + migrations
Dir["lib/storage/active_record/backend_models/*.rb"].each {|file| require file }
Dir["lib/storage/active_record/*.rb"].each {|file| require file }

# Storage using custom active record connection
# Just like the Rails :)
#
# Store every object instantly, no pooling

class StorageActiveRecord < StorageDbAbstract
  include Singleton

  def initialize
    super
    # always enabled
    @config[:enabled] = true

    ActiveRecord::Base.establish_connection(
      @config[:connection]
    )

    @pool = Array.new
  end

  # Create tables in DB
  def init
    Dir["lib/storage/active_record/migrations/*.rb"].each {|file| require file }
    ActiveRecordInitMigration.up
  end

  # Drop tables in DB
  def deinit
    Dir["lib/storage/active_record/migrations/*.rb"].each {|file| require file }
    ActiveRecordInitMigration.down
  end

  # Store object
  def store( obj )
    case obj.class.to_s
    when 'MetarCode' then store_metar( obj )
    when 'Weather' then store_weather( obj )
    else other_store( obj )
    end

    check_pool_size
  end

  # Add ActiveRecord object to pool without processing it
  def add_ar_object_to_pool( obj )
    @pool << obj
    
    check_pool_size
  end

  # Flush object from pool to DB
  def flush
    # saving each object
    puts "StorageActiveRecord flushing #{@pool.size} objects"
    t = Time.now
    ActiveRecord::Base.transaction do
      @pool.each do |o|
        res = o.save

        if res == false
          err_msg = "StorageActiveRecord errors: #{o.errors.inspect}"
          puts err_msg
          AdvLog.instance.logger( self ).warn( "#{err_msg}   -   #{o.inspect}" )
          # TODO move it outside, more type of error handling
        end
      end
    end
    puts "#{self.class.to_s} - storing #{@pool.size} object - #{Time.now.to_f - t.to_f} s" if SHOW_STORAGES_TIME_INFO

    # clearing pool
    @pool = Array.new
  end

  # Set flag if this city stores metar or weather
  # When city has no metars and we want to find metar it has to search through
  # all record which is log task
  def update_logged_flag
    cities = CityProxy.instance.cities_array
    cities.each do |ch|
      wa = WeatherArchive.find(:last, :conditions => {:city_id => ch[:id]})
      wma = WeatherMetarArchive.find(:last, :conditions => {:city_id => ch[:id]})
      c = City.find_by_id( ch[:id] )

      c.update_attributes!({
        :logged_metar => !wma.nil?,
        :logged_weather => !wa.nil?,
      })
    end
  end

  private

  # Check pool size and perform flush
  def check_pool_size
    # flushing
    if @pool.size >= @config[:pool_size].to_i
      flush
    end
  end

  def store_metar( obj )
    # wrong records can be not saved - there are always raw metars in text files
    return unless obj.valid?
    h = {
      :time_from => obj.output[:time],
      :time_to => obj.output[:time] + MetarCode::TIME_INTERVAL,
      :temperature => obj.output[:temperature],
      :pressure => obj.output[:pressure],
      :wind => obj.output[:wind_mps],
      :snow_metar => obj.output[:snow_metar],
      :rain_metar => obj.output[:rain_metar],
      :raw => obj.raw,
      :city_id => obj.city_id,
    }
    # updating metar if stored in DB
    wma = WeatherMetarArchive.find(:last, :conditions => {:city_id => obj.city_id, :time_from => obj.output[:time], :raw => obj.raw} )
    if wma.nil?
      wma = WeatherMetarArchive.new( h )
    else
      wma.update_attributes( h )
    end
    
    @pool << wma
  end

  def store_weather( obj )
    # wrong records can be not saved - there are always raw metars in text files
    return unless obj.valid?
    h = {
      :time_from => obj.data[:time_from],
      :time_to => obj.data[:time_to],
      :temperature => obj.data[:temperature],
      :pressure => obj.data[:pressure],
      :wind => obj.data[:wind],
      :snow => obj.data[:snow],
      :rain => obj.data[:rain],
      :city_id => obj.definition[:id],
      :weather_provider_id => obj.data[:weather_provider_id]
    }
    # updating metar if stored in DB
    wa = WeatherArchive.find(
      :last,
      :conditions => {
        :city_id => obj.definition[:id],
        :time_from => obj.data[:time_from],
        :weather_provider_id => obj.data[:weather_provider_id]
      }
    )
    
    if wa.nil?
      wa = WeatherArchive.new( h )
    else
      wa.update_attributes( h )
    end

    @pool << wa
  end

end
