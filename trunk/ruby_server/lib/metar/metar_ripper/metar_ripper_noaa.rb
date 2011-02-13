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


require './lib/metar/metar_ripper/metar_ripper_abstract.rb'

class MetarRipperNoaa < MetarRipperAbstract

  # remove time information, which is not part of metar
  REMOVE_TIME_BEFORE_METAR = true


  def url( city)
    # u = "http://weather.noaa.gov/pub/data/observations/metar/stations/#{city.upcase}.TXT"
    # u = "http://weather.noaa.gov/pub/data/observations/metar/decoded/#{city.upcase}.TXT"
    u = "http://weather.noaa.gov/pub/data/observations/metar/stations/#{city.upcase}.TXT"
    return u
  end

  def process( body )

    if REMOVE_TIME_BEFORE_METAR
      # remove 2010/12/09 18:35\n
      body.gsub!(/\d{4}\/\d{1,2}\/\d{1,2} \d{1,2}\:\d{1,2}\s*/,' ')
    end

    body.gsub!(/\n/,' ')
    body.gsub!(/\t/,' ')
    body.gsub!(/\s{2,}/,' ')
    return body.strip
  end

end
