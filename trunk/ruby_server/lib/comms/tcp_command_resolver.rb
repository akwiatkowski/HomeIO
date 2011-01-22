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
      :string => string_command,
      # to_s - xmpp4r's from is not string
      :from => from.to_s
    }
    puts "TcpCommandResolver tcp_command.inspect - #{tcp_command.inspect}"
    response = SupervisorClient.new.send_to_server( tcp_command )
    puts "TcpCommandResolver response.inspect - #{response.inspect}"
    last_response = SupervisorClient.wait_for_task( response.fetch_id )
    puts "TcpCommandResolver last_response.inspect - #{last_response.inspect}"
    return last_response[:response]
  end

end
