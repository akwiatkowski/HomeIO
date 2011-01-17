#!/usr/bin/ruby1.9.1
#encoding: utf-8

require './lib/plugins/im/bots/im_bot_abstract.rb'
require "xmpp4r"

# Xmpp4rBot - should works better

class Xmpp4rBot < ImBotAbstract
  include Singleton

  # Connect to server
  def initialize
    super
  end

  private

  # Start bot code
  def _start
    @client = Jabber::Client.new(Jabber::JID::new( @config[:login] ))
    @client.connect
    @client.auth( @config[:password] )
    @client.send(Jabber::Presence.new.set_type(:available))

    @client.add_message_callback do |m|
      begin

        # only valid messages
        if m.chat_state == :active and not m.body.nil?

          begin
            response = PROCESSOR.process_command( m.body, m.from )
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
  
end
