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

require 'lib/plugins/im/bots/im_bot_abstract'
require "xmpp4r"

# for fixing problems
Jabber::warnings = true

# Xmpp4rBot - should works better

class Xmpp4rBot < ImBotAbstract
  include Singleton

  # status types:
  # available
  STATUS_AVAIL = :available

  # Change IM bot status
  #
  # type = :away, :chat, :dnd, :available, :xa
  def change_status( type = STATUS_AVAIL, status = nil )
    @status_type = type
    @status_status = status

    p = Jabber::Presence.new
    p.set_show( @status_type )
    p.set_status( @status_status )
    @client.send( p )
  end
  
  # Change IM bot status
  def change_status_only_text( status = nil )
    @status_status = status
    p = Jabber::Presence.new
    #p.set_show( @status_type )
    p.set_status( @status_status )
    @client.send( p )
  end

  # Debug information
  def debug
    puts "XMPP"
    #puts "self.client.fd.eof #{@client.fd.eof}"
    puts "self.client.fd.sync #{@client.fd.sync}"
    puts "self.client.fd.sync_close #{@client.fd.sync_close}"
    #puts "self.client.status #{@client.status}"
    puts "\n"
  end



  private

  # TODO check if there is need for method to reconnect
  # check Jabber::Stream for @status (has accesor)

  # Start bot code
  def _start
    puts "Connecting #{self.class.to_s} at #{Time.now}"

    @jid = Jabber::JID::new( @config[:login] )
    @jid.domain = @config[:domain]
    @jid.resource = 'HomeIO'
    
    @client = Jabber::Client.new( @jid )

    _connect_bot_and_process_msgs
  end

  def _connect_bot_and_process_msgs
    @client.connect
    @client.auth( @config[:password] )

    # startup status
    @client.send(Jabber::Presence.new.set_type(:available))
    #change_status( STATUS_AVAIL, nil )

    @client.add_message_callback do |m|
      begin
        # only valid messages
        # first version
        #if m.chat_state == :active and not m.body.nil?
        # used for situation when multiple clients are logged onto same account
        if (m.chat_state == :active or m.chat_state.nil?) and not m.body.nil?

          begin
            response = @processor.process_command( m.body, m.from )
          rescue => e
            log_error( self, e )
            show_error( e )
            response = 'Error'
          end

          # send response
          msg = Jabber::Message::new(m.from, response)
          msg.type = :chat
          @client.send( msg )
        end

      rescue => e
        # xmpp4r die quietly when exception hit callback
        log_error( self, e )
        show_error( e )
      end
    end
  end

  # Stop bot
  def _stop
    @client.close
  end

end
