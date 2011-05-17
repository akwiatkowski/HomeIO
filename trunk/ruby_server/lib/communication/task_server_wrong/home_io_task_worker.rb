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

require "lib/communication/task_server/task_worker"
require "lib/communication/task_server/workers/home_io_standard_worker"

# Worker for HomeIO, process command in queue
#
# If command is :test when always return :od

class HomeIoTaskWorker < TaskWorker

  private

  # Process one task
  #
  # :call-seq:
  #   _process_task( TcpTask )
  def _process_task(q)
    # standard test command
    if q.command == :test
      q.response = :ok
      return q
    end

    # process command using standardized worker
    q.response = HomeIoStandardWorker.instance.process(q)
    return q

  end

end