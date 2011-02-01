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

require './lib/plugins/im/bots/im_bot_abstract.rb'
require "xmpp4r"

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



  private

  # TODO check if there is need for method to reconnect
  # check Jabber::Stream for @status (has accesor)

  # Start bot code
  def _start
    @jid = Jabber::JID::new( @config[:login] )
    @jid.domain = @config[:domain]
    
    @jid.domain = "jabbim.pl"
    @client = Jabber::Client.new( @jid )

    Thread.abort_on_exception=true
    _keep_alive_connection
    #_keep_alive_status

    # when keepalive is not used it is needed to connect bot to server
    #_connect_bot, TODO rewrite, it is without echo
  end

  def _connect_bot
    @client.connect
    @client.auth( @config[:password] )

    # startup status
    @client.send(Jabber::Presence.new.set_type(:available))
    #change_status( STATUS_AVAIL, nil )

    @client.add_message_callback do |m|
      begin

        #puts "#{m.chat_state} - #{m.body}"

        # only valid messages
        # first version
        #if m.chat_state == :active and not m.body.nil?
        # used for situation when multiple clients are logged onto same account
        if (m.chat_state == :active or m.chat_state.nil?) and not m.body.nil?

          begin
            response = @processor.process_command( m.body, m.from )
          rescue => e
            log_error( self, e )
            puts e.inspect
            puts e.backtrace
            response = 'Error'
          end

          # send response
          msg = Jabber::Message::new(m.from, response)
          msg.type = :chat
          @client.send( msg )
        end
      rescue => e
        # bigger error
        log_error( self, e )
        puts e.inspect
        puts e.backtrace
      end
    end
  end

  # New keep alive thread - change status
  # ... or it should be
  def _keep_alive_status
    Thread.new{
      loop do
        # only execeute when connected
        if @client.status == Jabber::Stream::CONNECTED
          # store old
          status = @status_status
          type = @status_type

          # set new
          change_status( :dnd, 'Bazinga!' )
          # wait a little
          sleep(1)

          # set old
          change_status( type, status )
        end
        
        # wait more
        sleep(30*60)
      end
    }
  end

  # New keep alive thread - check if bot is connected
  # ... or it should be
  def _keep_alive_connection
    Thread.new{
      loop do
        if @client.status == Jabber::Stream::DISCONNECTED
          puts "Connecting #{self.class.to_s} at #{Time.now}"
          _connect_bot
        end

        sleep(10)
        #sleep(120)
      end
    }
  end
  
end
