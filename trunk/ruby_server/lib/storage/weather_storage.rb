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
require File.join Dir.pwd, 'lib/utils/core_classes'
require File.join Dir.pwd, 'lib/metar/metar_code'
require File.join Dir.pwd, 'lib/utils/dev_info'
require File.join Dir.pwd, 'lib/weather_ripper/weather'

# Basic raw weather (non-metar) storage in text files

class WeatherStorage
  include Singleton
  
  def store( obj )
    # Store only raw metars
    return nil unless obj.kind_of?( Weather )

    return store_weather( obj )
  end

  # Prepare main directories
  def init
    # not needed, delete?
    # prepare_main_directories
  end

  def destroy
    # wont be implemented!
  end

  def flush
  end

  # Raw storage - always enabled
  def enabled
    return true
  end


  private

  # Store weather in files
  def store_weather( obj )
    # invalid metars won't be stored
    return :invalid unless obj.valid?

    prepare_directories( obj )
    # TODO performance issue!
    #return :was_logged unless not_logged?( obj )
    return :ok if append_weather( obj )
    return :failed
  end

  # Check if weather wasn't already logged
  # Warning: performance is hellish.
  # TODO: rewrite this to use many files
  def not_logged?( obj )
    fp = filepath( obj )
    text_line = obj.text_weather_store_string

    if File.exists?( fp )
      f = File.open( fp, "r" )
      f.each_line do |l|
        # check every line
        if not l.index( text_line ).nil?
          # checked for substring - positive, metar was logged
          f.close
          return false 
        end
      end
      f.close
    end
    # file doesn't exist so not logged
    return true
  end

  # Append metar at end of log
  def append_weather( obj )
    f = File.open( filepath( obj ), "a" )
    f.puts obj.text_weather_store_string + "\n"
    f.close

    puts "Stored: #{obj.short_info}"
    DevInfo.instance.inc( self.class.to_s, :weathers_logged )

    return true
  end

  # Full path to file
  def filepath( obj )
    return File.join( WeatherRipper::WEATHER_DIR, obj.provider + ".txt")
  end

  # Prepare directory structure for
  def prepare_directories( obj )
    # not needed
    # dirs are prepared elsewhere
  end
  
end
