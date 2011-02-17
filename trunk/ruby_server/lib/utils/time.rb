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


# Time class additions

class Time

  # Show full time human formatted
  def to_human
    return self.localtime.strftime("%Y-%m-%d %H:%M:%S")
  end

  # Show full time human formatted without seconds
  def to_human_wo_seconds
    return self.localtime.strftime("%Y-%m-%d %H:%M")
  end

  # Show full time human formatted
  def to_timedate_human
    to_human
  end

  # Show time human formatted
  def to_time_human
    return self.localtime.strftime("%H:%M:%S")
  end

  # Show time human formatted without seconds
  def to_time_human_wo_seconds
    return self.localtime.strftime("%H:%M")
  end

  # Show date human formatted
  def to_date_human
    return self.localtime.strftime("%Y-%m-%d")
  end

  # Create begin of month time
  def utc_begin_of_month
    t = Time.utc(self.year, self.month, 1, 0, 0, 0)
    return t
  end

  # Create last second of month time
  def utc_end_of_month
    days = Time.days_in_month(self.month)
    t = Time.utc(self.year, self.month, days, 0, 0, 0)
    t += 24*3600 - 1
    return t
  end

  # Count days in month
  #
  # :call-seq:
  #   Time.days_in_month( Fixnum month ) => days in month in current year
  #   Time.days_in_month( Fixnum month, Fixnum year ) => days in month 
  def self.days_in_month(month, year = Time.now.year)
    return ((Date.new(year, month, 1) >> 1) - 1).day
  end


  # Create Time from YYYY-MM-DD HH:mm string format
  #
  # :call-seq:
  #   Time.create_time_from_string( String date, String time ) => Time
  def self.create_time_from_string(date, time)
    date =~ /(\d{4})-(\d{1,2})-(\d{1,2})/
    y = $1.to_i
    m = $2.to_i
    d = $3.to_i

    if time =~ /(\d{1,2}):(\d{1,2})/
      h = $1.to_i
      min = $2.to_i
    else
      h = 0
      min = 0
    end

    return Time.mktime(y, m, d, h, min, 0, 0)
  end


end