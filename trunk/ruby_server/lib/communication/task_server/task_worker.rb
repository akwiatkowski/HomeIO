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

require "lib/utils/start_threaded"
require "lib/communication/task_server/tcp_task"
require "lib/utils/adv_log"

# Worker search for new commands and execute them

class TaskWorker

  def initialize(queue)
    @queue = queue
    @mutex = Mutex.new
  end

  def start
    puts "Worker started"
    StartThreaded.start_threaded(1, self) do
      start_searching
    end
  end

  private

  # Search all queue for new task
  def start_searching
    #puts "#{self.class.to_s} Searching queue"
    t = nil
    @mutex.synchronize do
      # select all new
      qs = @queue.select { |q| q.is_new? }
      # select first on queue to run
      if qs.size > 0
        t = qs.first
        t.set_in_process!
      end
    end
    # process outside mutes
    process_task(t) unless t.nil?
  end

# Wrapper task processor
  def process_task(q)
    begin
      _process_task(q)
      q.set_done!
      #puts "Done"
    rescue => e
      q.set_error!(e.to_s)
      log_error(self, e)
      show_error(e)
    end
  end

# Method to override for executing task
  def _process_task(q)
  end

end