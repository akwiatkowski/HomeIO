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


require 'net/http'
require 'rubygems'
require 'hpricot'
require 'lib/storage/storage'
require 'lib/utils/adv_log'
#require 'lib/weather_ripper'
require 'lib/weather_ripper/utils/city_proxy'
require 'lib/weather_ripper/weather'

# Abstract class for all rippers

class WeatherAbstract

  attr_reader :defs

  # Id used in DB
  # attr_reader :id

  def initialize
    @config = ConfigLoader.instance.config( self.class )
    @defs = @config[:defs]
  end

  # Safec accesor
  #attr_reader :config
  def config
    return @config.clone
  end

  # Check weather for all configured cities
  def check_all
    @defs.each do |d|
      
      begin
        check_online( d )
      rescue => e
        # log errors using standarized method
        log_error( self, e )
        # when set it blow up everything to pieces :]
        if true == @config[:stop_on_error]
          raise e
        end
      end
    end
    # must have!
    Storage.instance.flush
  end

  # Run within begin rescue, some portals like changing schema
  def process( body_raw )
    begin
      return _process( body_raw )
    rescue => e
      # bigger error
      log_error( self, e )
      puts e.inspect
      puts e.backtrace
      
      # processor must return array of hashes
      return []
    end
  end

  #  def process( body_raw )
  #    raise 'Not implemented'
  #
  #    # this method should return Array of Hashes like this
  #    # [{
  #    #   :time_created => Time.now, # used for
  #    #   :time_from => unix_time_soon_from, # begin of perdiod for theese values
  #    #   :time_to => unix_time_soon_to,
  #    #   :temperature => temperatures[1][0].to_f, # in Celsius
  #    #   :pressure => pressures[1][0].to_f, # in hPa
  #    #   :wind_kmh => winds[1][0].to_f, # in km/h
  #    #   :wind => winds[1][0].to_f / 3.6, # in m/s - preferred
  #    #   :snow => snows[1][0].to_f, # in mm
  #    #   :rain => rains[1][0].to_f, # in mm
  #    #   :provider => 'Onet.pl' # provider name
  #    # }]
  #  end

  def weather_provider_id
    return id
  end

  #private

  # Fetching and storing
  def check_online( defin )
    body = fetch( defin )
    processed = process( body )
    weathers = Weather.create_from( processed, defin )
    
    #puts weathers.inspect
    weathers.each do |w|
      w.store
    end

    return weathers
  end

  # Download website
  def fetch( defin )
    body = Net::HTTP.get( URI.parse( defin[:url] ) )
    f = File.new('delme.txt','w')
    f.puts body
    f.close
    return body
  end

  # Create WeatherProvider object and/or get id
  def id
    return @id if defined?( @id ) and not @id.nil?

    # establish connection
    StorageActiveRecord.instance

    prov_name = self.class.provider_name

    wp = WeatherProvider.find_or_create_by_name( prov_name )
    wp.save!
    @id = wp.id
    return @id
  end

end
