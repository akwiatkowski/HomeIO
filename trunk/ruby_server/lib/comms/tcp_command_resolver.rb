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
#    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

require 'singleton'
require './lib/utils/adv_log.rb'
require './lib/supervisor/supervisor_client.rb'
require './lib/supervisor/supervisor_commands.rb'

# TCP command resolver
# Communicate to supervisor

class TcpCommandResolver
  include Singleton

  # Send command via tcp
  def process_command( string_command, from = 'N/A' )
    tcp_command = {
      :command => SupervisorCommands::IM_COMMAND,
      :params => {
        :string => string_command,
        :from => from.to_s
      }
    }

    # all commands are queued, all but 'help'
    wait = true
    if string_command == '?' or string_command == 'help'
      wait = false
    end
    
    response_task = SupervisorClient.send_to_server_uni( tcp_command, wait )

    return response_task.response
  end

end
