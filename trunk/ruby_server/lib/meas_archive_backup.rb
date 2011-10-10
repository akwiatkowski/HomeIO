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

require 'lib/utils/adv_log'
require 'lib/utils/config_loader'
require 'lib/storage/storage_active_record'
require 'lib/storage/active_record/backend_models/meas_type'
require 'lib/storage/active_record/backend_models/meas_archive'

# Start doing backup

class MeasArchiveBackup

  # amount of meas. fetched in 1 step
  #INTERVAL = 10_000
  INTERVAL = 2000

  # show some info
  VERBOSE = true

  # where are pid files
  DIR_PATH = "data/meas_archive_backup"

  def initialize
    @storage_ar = StorageActiveRecord.instance
    @logger = AdvLog.instance.logger(self)

    @meas_types = MeasType.all
    @count = MeasArchive.count

    @i = 0
    
    `mkdir -p #{DIR_PATH}`
  end

  def offset
    @i * INTERVAL
  end

  def limit
    INTERVAL
  end

  def start
    while @i == 0 or @fetched.size > 0
      @fetched = fetch
      export(@fetched)
      @i += 1
    end
  end

  def fetch
    t = Time.now
    ma = MeasArchive.order("id ASC").offset(offset).limit(limit).all
    puts "Fetched step #{@i}, time #{Time.now - t}, progress #{offset.to_f/@count.to_f}"
    return ma
  end

  def export(ma)
    name = "meas_archive_#{offset}_#{offset + limit}.csv"
    f = File.new( File.join(DIR_PATH, name), "w")
    f.puts "meas_type.name;time_from_unix;time_to_unix;raw;value;"

    ma.each do |m|
      meas_type_name = @meas_types.select{|mt| mt.id = m.meas_type_id}.first.name
      f.puts "#{meas_type_name};#{m.time_from.to_f};#{m.time_to.to_f};#{m.raw};#{m.value};"
    end

    f.close
  end

end

b = MeasArchiveBackup.new
b.start
