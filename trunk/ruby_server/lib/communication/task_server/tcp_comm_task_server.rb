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

require 'lib/communication/tcp/tcp_comm_server'
require 'lib/communication/task_server/tcp_task_queue'
require 'lib/utils/config_loader'

# Server used for processing TcpTask
#
# How to use:
# 1. Create server. Port is configured in TcpCommTaskServer.yml.
#
#   t = TcpCommTaskServer.new
#   t.start
#
# 2. Send TcpTask object to server.
#
#   task = TcpTask.factory({:command => :test})
#   res = TcpCommProtocol.send_to_server(task, t.port)
#
#   Note: Normal tasks has +command+ and is added to queue. There are also other type of command which will be
#         described later.
#
# 3. Wait for response

# Special commands:
# * queue
# * fetch        - return task by id. When task is added server return it with generated id. Fetching response get this
#                  task, of course when it is not ready it does not have result.
#
#                  Sample command: {:command => :fetch, :params => {:id => 1243}}

class TcpCommTaskServer < TcpCommServer

  # Initialize TCP server on port defined in config file
  def initialize
    @config = ConfigLoader.instance.config(self)

    puts "#{self.class.to_s} Creating queue"
    @queue = TcpTaskQueue.new
    @queue.start

    super(port)
  end

  # Add command to queue
  def process_command(command)
    # check if this was special command
    special_command_result = process_special_command(command)
    return special_command_result unless special_command_result.nil?

    command.generate_fetch_id!
    @queue.push(command)
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
      command.response = @queue
      return command
    end

    # this was not special command
    return nil
  end



end