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
    wait_for_communication_tested
  end

  def port
    @config[:port]
  end

  def hostname
    @config[:hostname]
  end

  # Execute command and fetch response from uC. Connection errors are rescued.
  #
  # :call-seq:
  #   fetch( Array command ex. ['0'], Fixnum response array size in bytes ex. 2 )
  def fetch(command_array, response_size)
    begin
      fetch_wo_rescue(command_array, response_size)
    rescue Errno::ECONNREFUSED => e
      log_error(self, e, "host #{hostname}, port #{port}, command_array #{command_array.inspect}, response_size #{response_size}")
      show_error(e)
      return []
    end
  end

  # Execute command and fetch response from uC
  #
  # :call-seq:
  #   fetch( Array command ex. ['0'], Fixnum response array size in bytes ex. 2 )
  def fetch_wo_rescue(command_array, response_size)
    # convert command array to string
    # <count of command bytes> <count of response bytes> <command bytes>
    str = command_array.size.chr + response_size.chr + command_array.collect { |c|
      if c.kind_of? Fixnum
        c.chr
      else
        c.to_s
      end
    }.join('')

    s = TCPSocket.open(hostname, port)
    s.puts(str)
    data = s.gets
    s.close # Close the socket when done

    return data
  end

  # Wait
  def wait_for_communication_tested
    loop do
      res_t = fetch(['t'], 2)
      res_s = fetch(['s'], 1)
      # hardware rs testing
      if res_s[0] == 0 and (res_t[0] * 256 + res_t[1]) == 12345
        puts "IoServer protocol ready"
        return true
      else
        puts "IoServer protocol Error"
        puts res_t.inspect
        puts res_s.inspect
      end
      sleep(0.5)
    end
  end

  # Convert string response to single number
  def self.string_to_number(io_result)
    raw_joined = 0
    return raw_joined if io_result.nil?
    io_result.each_byte do |b|
      raw_joined *= 256
      raw_joined += b
    end
    return raw_joined
  end

  # Convert string response to array
  def self.string_to_array(io_result)
    raw_array = []
    return raw_array if io_result.nil?
    io_result.each_byte do |b|
      raw_array << b
    end
    return raw_array
  end

end