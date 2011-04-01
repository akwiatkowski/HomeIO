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


# Array of bytes. Used for sending and retrieving data from uC.

class ByteArray

  def initialize(obj)
    # TODO array of string, array of fixnum, string, -1 as wildcard
    # store as array of fixnum
  end

  def to_array_of_string

  end

  def to_array_of_fixnum

  end

  # Convert byte array to one number
  def to_i

  end

  # Convert byte array to one string, used when sending via TCP socket.
  def to_s

  end

end