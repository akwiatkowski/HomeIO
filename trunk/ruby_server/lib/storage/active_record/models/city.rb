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


require 'yaml'
require './lib/weather_ripper.rb'

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

  # Create or update cities
  def self.create_or_update( h )
    c = City.find(:first, :conditions => {:id => h[:id]})

    if c.nil?
      puts "not found city #{h[:id]} - #{h[:name]}"
      res = City.new( h ).safe_save
      puts City.find_by_name( h[:name]).inspect
      return res
    else
      #puts "found city #{h[:id]} - #{c.id}, #{h[:name].to_s} - #{c.name.to_s}"
      puts h.inspect, c.inspect
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
      log_error( self, e, self.inspect )
    end
    return self
  end

  # Create cities from configuration
  def self.create_from_config
    puts "populating cities"
    
    WeatherCityProxy.instance.cities_array.each do |c|
      arc = City.find_by_id( c[:id] ).nil? ? City.new : City.find_by_id( c[:id] )
      arc.name = c[:name]
      arc.country = c[:country]
      arc.metar = c[:metar]
      arc.id = c[:id]
      arc.lat = c[:lat]
      arc.lon = c[:lon]
      arc.safe_save
    end
    
    #City.transaction do
    #  self.create_from_config_metar
    #  self.create_from_config_nonmetar
    #end
  end

  private

  # Create cities from configuration
  def self.create_from_config_metar
    cities = ConfigLoader.instance.config( MetarConstants::CONFIG_TYPE )[:cities]
    cities.each do |c|
      h = {
        :id => c[:id], # force id
        :name => c[:name],
        :country => c[:country],
        :metar => c[:code],
        :lat => c[:coord][:lat],
        :lon => c[:coord][:lon],
      }
      create_or_update( h )
    end
  end

  # Create cities from configuration (non metar cities)
  def self.create_from_config_nonmetar
    providers = WeatherRipper.instance.providers
    providers.each do |p|
      # iteration for every city in current provider
      # checking if this city is in table cities
      puts "#{p.class} - #{p.config[:defs].size}"

      p.config[:defs].each do |pc|

        h = {
          :id => pc[:id], # force id
          :name => pc[:city],
          :country => pc[:country],
          :lat => pc[:coord][:lat],
          :lon => pc[:coord][:lon],
        }

        puts "#{h[:id]} - #{h[:name]}"
        create_or_update( h )
        
      end

    end
  end

end
