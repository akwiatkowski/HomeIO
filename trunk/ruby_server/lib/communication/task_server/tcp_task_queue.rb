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

require 'lib/communication/task_server/tcp_task'
require 'lib/communication/task_server/home_io_task_worker'

# Every command sent to task server goes to task queue 

class TcpTaskQueue
  WORKERS_LIMIT = 2

  def initialize
    @queue = Array.new
    @workers = Array.new
    start
  end

  # Add command to queue
  def push(command)
    command = TcpTask.factory(command)
    @queue << command
  end

  # Search for task from queue
  def fetch_by_id(result_fetch_id)
    return @queue.select { |q| q.result_fetch_id == result_fetch_id }.first
  end

  # Start workers
  def start
    puts "Starting #{WORKERS_LIMIT} workers"
    @workers = Array.new
    WORKERS_LIMIT.times do
      w = HomeIoTaskWorker.new(@queue)
      w.start
      @workers << w
    end
  end
end