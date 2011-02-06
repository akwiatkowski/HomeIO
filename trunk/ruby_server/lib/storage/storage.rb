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


require 'singleton'
require 'lib/utils/constants'

# better way to load all files from dir
Dir["./lib/storage/*.rb"].each {|file| require file }

# Rips raw metar from various sites

class Storage
  include Singleton

  attr_reader :klasses

  def initialize
    @storages = [
      MetarStorage.instance,
      WeatherStorage.instance,
      DbSqlite.instance,
      #DbMysql.instance,
      #DbPostgres.instance
      StorageActiveRecord.instance
    ]

    # delete disabled
    @storages.delete_if{|s| s.enabled == false }

  end

  # One time initialization
  def init
    @storages.each do |s|
      s.init
    end
  end

  # One time destructive uninitialization
  def deinit
    # TODO insert warning or sth
    @storages.each do |s|
      s.deinit
    end
  end

  # Store object wherever it is possible
  def store( obj )
    store_outputs = Array.new
    @storages.each do |s|
      store_outputs << s.store( obj )
    end
    return store_outputs
  end

  # Flush all storage classes
  def flush
    @storages.each do |s|
      s.flush
    end
  end

  private


end
