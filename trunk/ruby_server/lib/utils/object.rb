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

class Object

  # Convert to String and fill zeroes to demanded size
  #
  # :call-seq:
  #   to_s2( proper string length ) => String
  def to_s2( places )
    tmp = self.to_s

    while( tmp.size < places )
      tmp = "0" + tmp
    end

    return tmp
  end

  # Convert numeric objects to String with rounding
  #
  # :call-seq:
  #   to_s_round( number precision ) => String
  def to_s_round( places = 1 )
    if self.nil?
      return nil
    end

    tmp = ( self * (10 ** places ) ).round.to_f
    tmp /= (10.0 ** places )
    return tmp
  end

end
