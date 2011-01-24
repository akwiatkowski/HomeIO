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


require './lib/storage/storage.rb'
require './lib/storage/storage_interface.rb'

# Downloaded weather model

class Weather
  include StorageInterface
  
  attr_reader :data, :defin

  # Processors return >1 records, Weather is for 1 record
  def self.create_from( data_array, defin )
    a = Array.new
    data_array.each do |da|
      a << Weather.new( da, defin )
    end
    return a
  end

  def initialize( data, defin )
    @data = data
    @defin = defin
  end

  # This weather provider
  def provider
    return @data[:provider].to_s
  end

  # Short information
  def short_info
    return "#{data[:provider].to_s}: #{defin[:city].to_s} @ #{data[:time_from].to_human} - #{data[:temperature]}"
  end

  # Is valid for storing?
  def valid?
    if data[:time_from].nil? or data[:time_to].nil? or data[:provider].nil? or data[:temperature].nil?
      return false
      # TODO add wind?
    end

    return true
  end

  # Store this object
  def store
    Storage.instance.store( self )
  end

  # Convert to hash object prepared to store in DB
  def to_db_data
    # time of saving
    data[:created_at] = Time.now if data[:created_at].nil?

    return {
      :data => {
        :city_id => defin[:city_id].to_s,
        :created_at => data[:created_at].to_i,
        :provider => "'#{data[:provider].to_s}'",
        :city => "'#{defin[:id].to_s}'",
        :lat => defin[:coord][:lat],
        :lon => defin[:coord][:lon],
        :time_from => data[:time_from].to_i,
        :time_to => data[:time_to].to_i,
        :temperature => data[:temperature],
        :wind => data[:wind],
        :pressure => data[:pressure],
        :rain => data[:rain],
        :snow => data[:snow]
      },
      :columns => [
        :city_id,
        :created_at,
        :provider,
        :city,
        :lat,
        :lon,
        :time_from,
        :time_to,
        :temperature,
        :wind,
        :pressure,
        :rain,
        :snow
      ]
    }
  end

  # One line inserted into raw weather logs
  def text_weather_store_string
    return "#{data[:time_created].to_i}; '#{defin[:city].to_s}'; #{data[:provider].to_s}; #{defin[:coord][:lat]}; #{defin[:coord][:lon]};   #{data[:time_from].to_i}; #{data[:time_to].to_i}; #{data[:temperature]}; #{data[:wind]}; #{data[:pressure]}; #{data[:rain]}; #{data[:snow]}"
  end


end
