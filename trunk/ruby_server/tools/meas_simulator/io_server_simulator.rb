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

# Simulate connected hardware to PC

class IoServerSimulator

  # Set up server simulator
  #
  # :call-seq:
  #   IoServerSimulator.new( tcp port )
  def initialize(port)
    @port = port
  end

  # Start threaded server
  def start
    start_measurements
    start_server

    # TODO init meas, start ui shoving thread
    # TODO start key interface (type commands and execute on enter, enter show UI)
    # TODO start tcp server
  end

  # Start measurement thread
  def start_measurements
    init_measurements
    StartThreaded.start_threaded(1, self) do
      simulate_new_measurements
    end
    sleep 1
  end

  # Configure measurements and set default values
  def init_measurements
    @meas_config = ConfigLoader.instance.config('MeasurementArray')
    @meas_types = Array.new
    @meas_raws = Array.new


    @meas_config[:array].each do |mc|
      mt = MeasurementType.new(mc)
      mt.add_foreign_real_measurement(mc[:simulator][:default_value])

      # add raw value of default real value
      # raws should be easier to manipulate
      @meas_raws << mt.raw
      @meas_types << mt
    end

    #puts @meas_types.inspect
  end

  # Add new simulated measurements
  def simulate_new_measurements
    (0...(@meas_types.size)).each do |i|
      # add new measurement using defined raw value
      @meas_types[i].add_foreign_raw_measurement(@meas_raws[i])
    end
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
          response = process_uc_command(command)
          puts "#{command.inspect} - #{response.inspect}"
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

  def process_uc_command(command)
    # TODO rewrite it to be more universal

    #str = command_array.size.chr + response_size.chr + command_array.collect { |c|
    command_array_size = command[0]
    response_array_size = command[1]
    command_array = command[2...(command.size)]

    puts command_array.inspect

    # TODO use action manager
    if command_array == 't'
      return 48.chr + 57.chr
    end

    if command_array == 's'
      return 0.chr
    end

    (0...(@meas_types.size)).each do |i|
      if [ command_array ] == @meas_types[i].command_array
        # measurement found
        response_raw = @meas_raws[i]
        response_array = Array.new

        # TODO rewrite
        if response_array_size == 1
          return (response_raw % 256).chr
        end

        if response_array_size == 2
          lsb = response_raw % 256
          msb = (response_raw - lsb) / 256
          return msb.chr + lsb.chr
        end

      end
    end

    # TODO
    return command
  end

  # Show user interface - measurement list
  def show_ui
    @meas_types.each do |m|
      puts "#{m.type.to_s.ljust(20)} #{m.raw.to_s.ljust(20)} #{m.value.to_s.ljust(20)} #{m.unit.to_s.ljust(12)} #{m.locale[:en].to_s.ljust(30)}"
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

Thread.abort_on_exception = true

port = IoProtocol.instance.port
s = IoServerSimulator.new(port)
s.start
#s.start_key
#s.init_measurements
#s.start_ui