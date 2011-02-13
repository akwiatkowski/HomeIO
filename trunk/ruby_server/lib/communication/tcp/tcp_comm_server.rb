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

require 'lib/communication/tcp/tcp_comm_protocol'
require 'lib/utils/adv_log'
require 'lib/utils/start_threaded'

# TCP Simple server

class TcpCommServer < TcpCommProtocol

  # When server crash it log backtrace and wait a little
  WRAPPER_INTERVAL = 5

  # Set up server
  #
  # :call-seq:
  #   TcpCommServer.new( tcp port )
  def initialize(port)
    @port = port
  end

  # Start threaded server
  def start
    start_server_wrapped
  end

  # Stop threaded server
  def stop
    @thread.thread.kill
  end

  private

  # Start wrapped in looped begin-rescue-end
  def start_server_wrapped
    @thread = StartThreaded.start_threaded(WRAPPER_INTERVAL, self) do
      start_server
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
          command  = comm_decode(s.recv(MAX_COMMAND_SIZE))
          # process command
          response = process_command(command)
          # reply response
          s.write(comm_encode(response))
          # say goodbye
        rescue => e
          log_error(self, e)
          show_error(e)
        ensure
          s.close
        end
      end
    end
  end

  # Simple test processor of command, send them back. Override it with real processing method.
  #
  # :call-seq:
  #   process_command( command to process ) => reply
  def process_command(command)
    return command
  end

end
