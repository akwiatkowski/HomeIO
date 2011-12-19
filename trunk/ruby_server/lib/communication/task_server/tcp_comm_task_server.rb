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

require File.join Dir.pwd, 'lib/communication/tcp/tcp_comm_server'
require File.join Dir.pwd, 'lib/communication/task_server/workers/home_io_standard_worker'
require File.join Dir.pwd, 'lib/utils/config_loader'

# Server used for processing TcpTask. Lite and working edition.

class TcpCommTaskServer < TcpCommServer

  # Initialize TCP server on port defined in config file
  def initialize
    @config = ConfigLoader.instance.config(self)
    @worker = HomeIoStandardWorker.instance
    super(port)
  end

  # Add command to queue
  def process_command(command)
    # check if this was special command
    special_command_result = process_special_command(command)
    return special_command_result unless special_command_result.nil?

    # instant process
    @worker.process(command)

    return command
  end

  # Port accessor
  def port
    return @config[:port]
  end

  private

  # Process commands which are no typical task
  # Special commands are described at the top of this file
  def process_special_command(command)
    if command.command == :fetch
      return @queue.fetch_by_id(command.params[:id])
    end
    if command.command == :queue
      command.response = @queue.queue
      return command
    end

    # this was not special command
    return nil
  end



end