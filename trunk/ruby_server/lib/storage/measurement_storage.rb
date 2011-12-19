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

require 'rubygems'
require 'json'
require 'singleton'
require File.join Dir.pwd, 'lib/utils/core_classes'
require File.join Dir.pwd, 'lib/utils/dev_info'
require File.join Dir.pwd, 'lib/storage/active_record/backend_models/meas_archive'

# Basic measurement storage in text files used when storage in DB is not possible

class MeasurementStorage
  include Singleton

  def store(obj)
    # Store only raw metars
    return nil unless obj.kind_of?(MeasArchive)
    return store_measurement(obj)
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

  # Used only as emergency
  def enabled
    false
  end

  private

  # Store weather in files
  def store_measurement(obj)
    append_measurement(obj)
  end

  # Append metar at end of log
  def append_measurement(obj)
    #str = obj.attributes.to_json
    str = obj.to_json

    f = File.open(filepath, "a")
    f.puts(str + "\n")
    f.close

    DevInfo.instance.inc(self.class.to_s, :measurements_backup_stored)

    return true
  end

  # Full path to file
  def filepath
    return File.join(
      Constants::DATA_DIR,
      'Measurements.json'
    )
  end


end
