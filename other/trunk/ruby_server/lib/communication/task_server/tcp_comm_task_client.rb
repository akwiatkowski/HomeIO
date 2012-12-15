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
require File.join Dir.pwd, 'lib/communication/tcp/tcp_comm_server'
require File.join Dir.pwd, 'lib/utils/config_loader'

# Client abstract for creating clients to task server

class TcpCommTaskClient < TcpCommProtocol
  include Singleton

  # Initialize TCP server on port defined in config file
  def initialize
    @config = ConfigLoader.instance.config('TcpCommTaskServer')
  end

  # Port accessor
  def port
    return @config[:port]
  end

  # Server accessor
  def server
    return "localhost" if @config[:server_ip].nil?
    return @config[:server_ip]
  end

  # Send command to server, receive reply
  #
  # :call-seq:
  #   send_to_server( TcpTask command ) => send to localhost
  #   send_to_server( TcpTask command, String server ip/host ) => send to server
  def send_to_server(comm, _server = server)
    # create TcpTask from hash if needed
    comm = TcpTask.factory(comm)
    self.class.send_to_server(comm, port, _server)
  end

end