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
require 'lib/utils/adv_log'
require 'lib/communication/task_server/tcp_comm_task_client'

# Command resolver for IM bots. It get benefits from one internal commands processor and queue.

class ImCommandResolver
  include Singleton

  NO_WAIT_COMMANDS = [
    '?',
    'help',
    'queue'
  ]

  # Send command via tcp
  def process_command(string_command, from = 'N/A')
    tcp_command = encapsulate_command(string_command, from)

    # all commands are queued, all but 'help' and 'queue'
    wait = true
    if ([string_command] & NO_WAIT_COMMANDS).size > 0
      wait = false
    end

    response_task = TcpCommTaskClient.instance.send_to_server_and_wait(tcp_command)

    #return response_task.response
    return response_task.response.inspect
  end

  private

  def encapsulate_command(string_command, from)
    split = string_command.split(" ")

    return {
      :command => split.shift,
      :params => split,
      :channel => :im
    }
  end

end
