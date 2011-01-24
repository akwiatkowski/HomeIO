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


# Some new methods

class Time

  # Show full time human formatted
  def to_human
    return self.localtime.strftime("%Y-%m-%d %H:%M:%S")
  end

  def to_timedate_human
    to_human
  end

  def to_time_human
    return self.localtime.strftime("%H:%M:%S")
  end

  def to_date_human
    return self.localtime.strftime("%Y-%m-%d")
  end

  # Ustawia początek danego miesiąca
  def utc_begin_of_month
    t = Time.utc( self.year, self.month, 1, 0, 0, 0)
    #puts "* " + t.to_s
    return t
  end

  # Ilość dni w miesiącu
  def self.days_in_month( month, year = Time.now.year )
    return ((Date.new(year, month, 1) >> 1) - 1).day
  end

  # Ustawia koniec danego miesiąca
  def utc_end_of_month
    days = Time.days_in_month( self.month )
    t = Time.utc( self.year, self.month, days, 0, 0, 0)
    # przejdź na koniec danego dnia
    t += 24*3600 - 1
    #puts "- " + t.to_s
    return t
  end

end