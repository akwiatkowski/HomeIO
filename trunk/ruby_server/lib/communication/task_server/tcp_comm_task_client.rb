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
require 'lib/communication/tcp/tcp_comm_server'
require 'lib/communication/task_server/tcp_task_queue'
require 'lib/utils/config_loader'

# Client abstract for creating clients to task server

class TcpCommTaskClient < TcpCommProtocol
  include Singleton

  # When waiting for result loop is checking every this seconds
  CHECK_EXEC_END_INTERVAL = 0.2
  
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
  #   send_to_server( TcpTask command )
  def send_to_server(comm)
    self.class.send_to_server(comm, port, server)
  end

  # After adding command to queue this method will wait until task is finished and return finished result
  #
  # :call-seq:
  #   wait_for_task( TcpTask from server ) => TcpTask with response
  def wait_for_task(task)
    command = TcpTask.factory(
        {
            :command => :fetch,
            :params => {
                :id => task.result_fetch_id
            }
        }
    )

    while true
      res = send_to_server(command)
      if res.fetch_is_ready?
        return res
      end
      sleep(CHECK_EXEC_END_INTERVAL)
    end
  end
end