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


require 'lib/storage/storage.rb'
require 'lib/storage/storage_interface.rb'

# HomeIO weather model. Used for storing in various store engines. When using ActiveRecord it could be little
# deprecated but it is a nice idea to not remove simple Sqlite support for future use in very low performance
# computers.

class Weather
  include StorageInterface

  # Weather data
  attr_reader :data
  # Provider definition
  attr_reader :definition

  # Weather processors return more than 1 record. This factory like method return instances built from array
  #
  # :call-seq:
  #   self.create_from( output from weather provider processor, weather provider definition ) => array of Weather
  def self.create_from(data_array, definition)
    a = Array.new
    data_array.each do |da|
      a << Weather.new(da, definition)
    end
    return a
  end

  # Convert to Weather model. Usable for storing in various storage engines.
  #
  # :call-seq:
  #   self.initialize( one record from weather provider processor, weather provider definition )
  def initialize(data, definition)
    @data       = data
    @definition = definition
  end

  # This weather provider
  #
  # :call-seq:
  #   provider => String
  def provider
    return @data[:provider].to_s
  end

  # Short information used for printing on screen
  #
  # :call-seq:
  #   short_info => String
  def short_info
    str = "#{data[:provider].to_s}: #{definition[:city].to_s} @ #{data[:time_from].to_human}"
    str += "   #{data[:temperature]}C" unless data[:temperature].nil?
    str += "   #{data[:pressure]}hPa" unless data[:pressure].nil?
    str += "   #{data[:wind].to_s_round(1)}m/s" unless data[:wind].nil?
    str += "   #{data[:rain].to_s_round(1)}r.mm" unless data[:rain].nil?
    str += "   #{data[:snow].to_s_round(1)}s.mm" unless data[:snow].nil?
    return str
  end

  # Return true is Weather valid for storing. It means that there is information about time period, weather provider,
  # temperature and wind speed.
  #
  # :call-seq:
  #   valid? => true or false
  def valid?
    if data[:time_from].nil? or data[:time_to].nil? or data[:provider].nil? or data[:temperature].nil? or data[:wind].nil?
      return false
    end
    return true
  end

  # Store this object
  def store
    Storage.instance.store(self)
  end

  # Convert to hash object for storing in DB. Created (but used also by) for first, non ActiveRecord storage engines.
  #
  # :call-seq:
  #   to_db_data? => Hash used for storing
  def to_db_data
    # time of saving
    data[:created_at] = Time.now if data[:created_at].nil?

    return {
        :data    => {
            :city_id     => definition[:city_id].to_s,
            :created_at  => data[:created_at].to_i,
            :provider    => "'#{data[:provider].to_s}'",
            :city        => "'#{definition[:id].to_s}'",
            :lat         => definition[:coord][:lat],
            :lon         => definition[:coord][:lon],
            :time_from   => data[:time_from].to_i,
            :time_to     => data[:time_to].to_i,
            :temperature => data[:temperature],
            :wind        => data[:wind],
            :pressure    => data[:pressure],
            :rain        => data[:rain],
            :snow        => data[:snow]
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
  #
  # :call-seq:
  #   text_weather_store_string => String
  def text_weather_store_string
    return "#{data[:time_created].to_i}; '#{definition[:city].to_s}'; #{data[:provider].to_s}; #{definition[:coord][:lat]}; #{definition[:coord][:lon]};   #{data[:time_from].to_i}; #{data[:time_to].to_i}; #{data[:temperature]}; #{data[:wind]}; #{data[:pressure]}; #{data[:rain]}; #{data[:snow]}"
  end


end
