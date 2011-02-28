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
require 'socket'
require 'lib/utils/config_loader'

# Singleton for fetching measurements using connected hardware

class IoProtocol
  include Singleton

  MAX_COMMAND_SIZE = 256

  def initialize
    @config = ConfigLoader.instance.config(self.class.to_s)
  end

  def port
    @config[:port]
  end

  def hostname
    @config[:hostname]
  end

  def fetch(command_array, response_size)
    s = TCPSocket.open(hostname, port)
    # <count of command bytes> <count of response bytes> <command bytes>
    str = command_array.size.chr + response_size.size.chr + command_array.collect{|c| c.chr}.join('')
    s.puts(str)
    data = s.gets
    s.close # Close the socket when done

    return data
  end
end