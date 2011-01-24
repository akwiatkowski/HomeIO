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


require './lib/metar/metar_ripper/metar_ripper_abstract.rb'

class MetarRipperAllMetSat < MetarRipperAbstract

  def url( city)
    u = "http://pl.allmetsat.com/metar-taf/polska.php?icao=#{city.upcase}"
    return u
  end

  def process( body )
    reg = /<b>METAR:<\/b>([^<]*)<br>/
    body = body.scan(reg).first.first
    body.gsub!(/\n/,' ')
    body.gsub!(/\t/,' ')
    body.gsub!(/\s{2,}/,' ')
    return body.strip
  end

end
