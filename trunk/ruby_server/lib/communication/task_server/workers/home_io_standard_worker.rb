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
require "lib/communication/db/extractor_basic_object"
require "lib/communication/task_server/tcp_task"
require "lib/communication/task_server/workers/home_io_standard_commands"

# Standard, universal worker used for commands sent on main port
# Store table of standard remote commands and can execute only TcpTask

class HomeIoStandardWorker
  include Singleton

  def initialize
    @commands = commands
  end

  # Process command/TCP task
  def process(tcp_task)
    #puts tcp_task.class.to_s
    #puts tcp_task.inspect

    # process only TcpTask
    return :wrong_object_type unless tcp_task.kind_of? TcpTask

    # select command
    command = @commands.select { |c| c[:command].select { |d| d.to_s == tcp_task.command.to_s }.size > 0 }
    return :wrong_command if command.size == 0

    command = command.first
    begin
      return command[:proc].call(tcp_task.params)
    rescue => e
      command = TcpTask.new
      command.set_error!(:processing_error, e.to_s)
      log_error(self, e, "command: #{tcp_task.inspect}")
      show_error(e)
      return { :error => e.to_s }
    end
  end

  private

  # Commands definition
  def commands
    HomeIoStandardCommands.commands
  end

end