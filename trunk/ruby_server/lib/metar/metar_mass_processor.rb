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
require File.join Dir.pwd, 'lib/metar/metar_logger'
require File.join Dir.pwd, 'lib/storage/metar_storage'

# Load raw metar logs and process it
#
# Warning:
# Storage.instance.flush needed after finish

class MetarMassProcessor
  include Singleton

  VERBOSE_EVERY = 50

  # Metar logger cities definition
  attr_reader :cities

  def initialize
    # cities from definitions
    #@cities = MetarLogger.instance.cities.collect{|c| c[:code]}
    # cities logged on disk
    @cities = MetarStorage.cities_logged
  end

  # Process everything
  def process_all
    _process_all
    Storage.instance.flush
  end

  # Process everything for one city
  # *city* - metar code
  def process_all_for_city( city )
    _process_all_for_city( city )
    Storage.instance.flush
  end

  # Process one month for city
  # *city* - metar code
  # *year*
  # *month*
  def process_month_for_city( city, year, month )
    _process_month_for_city( city, year, month )
    Storage.instance.flush
  end




  private

  # Process everything
  def _process_all
    @cities.sort.each do |c|
      _process_all_for_city( c )
    end
  end

  # Process everything for one city
  # *city* - metar code
  def _process_all_for_city( city )
    puts "Processing city #{city} (#{Time.now.to_s})"
    logs = MetarStorage.dirs_per_city( city )
    logs.keys.sort.each do |year|
      logs[ year ].sort.each do |month|
        _process_month_for_city( city, year, month )
      end
    end
  end

  # Process one month for city
  # *city* - metar code
  # *year*
  # *month*
  def _process_month_for_city( city, year, month )
    puts "\n", "*"*80
    puts "Processing city #{city} - #{year}.#{month}"
    puts "*"*80, "\n"

    file_path = MetarStorage.filepath( city, year, month )

    count = 0
    valid_count = 0

    f = File.open( file_path )
    f.each_line do |metar|
      
      mc = MetarCode.process( metar, year, month, MetarConstants::METAR_CODE_RAW_LOGS )
      mc.store
      
      count += 1
      valid_count += 1 if mc.valid?
      if (count % VERBOSE_EVERY) == 0
        puts " #{count} metars processed and stored, #{valid_count} valid"
      end
    end
    f.close
  end

end
