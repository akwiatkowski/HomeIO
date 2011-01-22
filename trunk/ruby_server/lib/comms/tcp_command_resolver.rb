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

    response_task = SupervisorClient.new.send_to_server( tcp_command )
    last_response = SupervisorClient.wait_for_task( response_task )

    return last_response.response
  end

end
