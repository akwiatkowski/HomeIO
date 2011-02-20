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
require 'lib/utils/constants'

require "lib/storage/metar_storage"
require "lib/storage/weather_storage"
require "lib/storage/storage_active_record"

# Rips raw metar from various sites

class Storage
  include Singleton

  attr_reader :klasses

  def initialize
    @storage = [
      MetarStorage.instance, # strongly needed
      WeatherStorage.instance, # recommended
      #DbSqlite.instance, # is not so fresh
      #DbMysql.instance, # not implemented
      #DbPostgres.instance, # not implemented
      StorageActiveRecord.instance # obligatory
    ]

    # delete disabled
    @storage.delete_if { |s| s.enabled == false }

  end

  # One time initialization
  def init
    @storage.each do |s|
      s.init
    end
  end

  # One time destructive uninitialization
  def destroy
    # TODO insert warning or sth
    @storage.each do |s|
      s.destroy
    end
  end

  # Store object wherever it is possible
  def store(obj)
    store_outputs = Array.new
    @storage.each do |s|
      store_outputs << s.store(obj)
    end
    return store_outputs
  end

  # Flush all storage classes
  def flush
    @storage.each do |s|
      s.flush
    end
  end

  private


end
