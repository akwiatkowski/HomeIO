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

# TODO
# rewrite as universal server
# and it will be server for task
# it has queue inside
# create queue, array object
# create worker
# queue create workers at start

require 'lib/communication/io_comm/io_protocol'
require 'lib/utils/start_threaded'
require 'lib/measurements/measurement_array'

# Simulate connected hardware

class IoServerSimulator

  # When server crash it log backtrace and wait a little
  WRAPPER_INTERVAL = 5

  # Set up server
  #
  # :call-seq:
  #   IoServerSimulator.new( tcp port )
  def initialize(port)
    @port = port
  end

  # Start threaded server
  def start
    start_server
  end

  # Start TCP server, accept connection, process commands and send reply
  def start_server
    dts = TCPServer.new(@port)
    puts "#{self.class.to_s} - started at port #{@port}"

    loop do
      Thread.start(dts.accept) do |s|
        begin
          # command received
          command = s.recv(IoProtocol::MAX_COMMAND_SIZE)
          # process command
          response = command
          # reply response
          s.write(response)
        rescue => e
          show_error(e)
        ensure
          # say goodbye
          s.close
        end
      end
    end
  end

  def start_measurements
    @meas_config = ConfigLoader.instance.config('MeasurementArray')
    @meas_types = Array.new

    @meas_config[:array].each do |mc|
      mt = MeasurementType.new(mc)
      mt.add_foreign_real_measurement(mc[:simulator][:default_value])
      @meas_types << mt
    end

    #@ma = MeasurementArray.instance
    #@meas_types = @ma.types_array

    puts @meas_types.inspect
  end

  # Start simple user interface
  def start_ui
    puts "ui"
    Thread.abort_on_exception=true
    @meas_types.each do |m|
      puts "#{m.type.to_s.ljust(20)} #{m.raw.to_s.ljust(20)} #{m.value.to_s.ljust(20)} #{m.unit.to_s.ljust(5)}"
    end
  end

  def start_key
    loop do
      begin
        # this part only works after enter
        c = STDIN.read_nonblock(1)
        puts "I found a #{c}"
        return true if c == 'Q'
      rescue Errno::EAGAIN
        sleep(0.2)
      rescue EOFError
        return
      end
    end
  end

end

port = IoProtocol.instance.port
s = IoServerSimulator.new(port)
#s.start
#s.start_key
s.start_measurements
s.start_ui