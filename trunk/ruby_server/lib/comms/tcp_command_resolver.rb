#!/usr/bin/ruby1.9.1
#encoding: utf-8

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
