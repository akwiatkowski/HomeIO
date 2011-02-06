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
#    along with HomeIO.  If not, see <http://www.gnu.org/licenses/>.

require 'lib/communication/tcp/tcp_comm_server'
require 'lib/communication/task_server/tcp_task_queue'

# Server used for processing TcpTask

class TcpCommTaskServer < TcpCommServer

  def initialize(*args)
    super(*args)
    @queue = TcpTaskQueue.new
    @queue.start
  end

  # Add command to queue
  def process_command(command)
    @queue.push( command )
  end

end