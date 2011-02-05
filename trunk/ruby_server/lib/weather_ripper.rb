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
require 'lib/utils/config_loader.rb'

require 'lib/weather_ripper/rippers/weather_onet_pl.rb'
require 'lib/weather_ripper/rippers/weather_wp_pl.rb'
require 'lib/weather_ripper/rippers/weather_interia_pl.rb'

# Fetch weather information from various web pages

class WeatherRipper
  include Singleton

  # Array of providers instances
  attr_reader :providers

  # Weather raw logs are stored here
  WEATHER_DIR = File.join(
    Constants::DATA_DIR,
    'weather'
  )

  # Setup providers
  def initialize
    prepare_directories

    @@config = ConfigLoader.instance.config( self.class )

    @providers = [
      WeatherOnetPl.new, # detailed
      WeatherWpPl.new,
      WeatherInteriaPl.new
    ]

    puts "#{self.class.to_s} init - #{@providers.size} providers"
  end

  # Fetch weather from all providers, and all cities
  def fetch
    WeatherCityProxy.instance.post_init

    @providers.each do |p|
      p.check_all
    end
    return {:status => :ok}
  end

  # Fetch weather from all providers, and all cities
  def start
    fetch
  end

  private

  # Prepare directories for saving raw weather data
  def prepare_directories
    if not File.exists?( Constants::DATA_DIR )
      Dir.mkdir( Constants::DATA_DIR )
    end

    if not File.exists?( WEATHER_DIR )
      Dir.mkdir( WEATHER_DIR )
    end
  end
end
