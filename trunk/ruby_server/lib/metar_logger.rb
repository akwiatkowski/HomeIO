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
require 'lib/utils/config_loader.rb'
require 'lib/metar/metar_constants.rb'
require 'lib/metar/metar_ripper/metar_ripper.rb'
require 'lib/metar/metar_code.rb'
require 'lib/metar/metar_mass_processor.rb'
require 'lib/weather_ripper/utils/city_proxy'

# Singleton for fetching and storing metar to other classes

class MetarLogger
  include Singleton

  # Cities definition array
  attr_reader :cities

  # Get cities list for fetching
  def initialize
    @cities = ConfigLoader.instance.config(self.class.to_s)[:cities]
    puts "#{self.class.to_s} init - #{@cities.size} cities"
  end

  ##
  # Get array of cities definitions used for metar fetching
  #
  # :call-seq:
  #    get_logged_cities => array of cities definitions fetched on disk
  def get_logged_cities
    require './lib/metar/metar_mass_processor.rb'
    mmp           = MetarMassProcessor.instance
    # array of codes of logged on disk
    logged_cities = mmp.cities
    # definitions from yaml
    metar_cities  = cities
    # only cities which has logs
    metar_cities  = metar_cities.select { |c| ([c[:code]] & logged_cities).size == 1 }
    # list of cities
    return metar_cities.sort { |c, d| c[:code] <=> d[:code] }
  end

  # Start by remote command
  #
  # :call-seq:
  #   start => array of metars
  def start
    # get cities id at start when needed
    CityProxy.instance.post_init

    o      = fetch_and_store
    # convert to array of metars
    o_raws = Array.new
    o.collect { |a| a[1] }.each do |ma|
      ma.each do |m|
        o_raws << m.raw
      end
    end

    return {:status => :ok, :data => o_raws}
  end

  # Fetch and store metar for all cities
  #
  # :call-seq:
  #   fetch_and_store => hash of arrays of MetarCodes
  def fetch_and_store
    o = _fetch_and_store
    Storage.instance.flush
    return o
  end

  # Fetch and store metar for city. Use all sites
  #
  # :call-seq:
  #   fetch_and_store_city => array of MetarCodes
  def fetch_and_store_city(metar_city)
    o = _fetch_and_store_city(metar_city)
    Storage.instance.flush
    return o
  end


  private

  # Fetch and store metar for all cities
  #
  # :call-seq:
  #    _fetch_and_store => hash of arrays of MetarCodes
  def _fetch_and_store
    h = Hash.new
    @cities.each do |c|
      metar_code    = c[:code]
      h[metar_code] = _fetch_and_store_city(metar_code)
    end
    return h
  end

  # Fetch and store metar for city
  # Use all sites
  #
  # Return array of MetarCode
  def _fetch_and_store_city(metar_city)
    year        = Time.now.year
    month       = Time.now.month

    # fetch metars
    m           = MetarRipper.instance
    o           = m.fetch(metar_city)

    # process them
    # *metar_array* - array of processed metars
    metar_array = MetarCode.process_array(o, year, month, MetarConstants::METAR_CODE_JUST_DOWNLOADED)

    # store them
    metar_array.each do |ma|
      # store as they were just downloaded
      ma.store
    end

    return metar_array
  end

end
