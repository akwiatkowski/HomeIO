#!/usr/bin/ruby1.9.1
#encoding: utf-8

require 'rubygems'
require 'singleton'
require "jabber4r/jabber4r"
# ugly fix for rexml in ruby 1.9, yuck!
require './lib/plugins/jabber/jabber_ugly_fix.rb'
require './lib/plugins/jabber/jabber_processor.rb'
require './lib/utils/config_loader.rb'

class JabberBot
  include Singleton

  PROCESSOR = JabberProcessor

  # Connect to server
  def initialize
  end

  def start
    @config = ConfigLoader.instance.config( self.class.to_s )

    @login = @config[:login]
    @password = @config[:password]
    @started = false

    #Thread.abort_on_exception = true
    #Thread.new{
    bot_loop
    #bot_thread
    #}
  end

  private

  def bot_loop
    loop do
      begin
        bot_thread
      #rescue
      end
      sleep(5)
    end
  end

  def bot_thread
    begin
      @started = true
      session = Jabber::Session.bind("#{@login}/homeio", @password)
      Thread.abort_on_exception=true
      my_thread = Thread.current
      mlid = session.add_message_listener do |message|

        # respond only for non blank messages
        if not message.body.to_s == ''
          begin
            response = PROCESSOR.process_command( message.body )
          rescue => e
            log_error( self, e )
            puts e.inspect
            puts e.backtrace
            response = 'Error'
          end
          message.reply.set_body( response ).send
        end

        # endword
        # my_thread.wakeup if message.body=="shutdown"
      end
      Thread.stop
      session.delete_message_listener(mlid)
    rescue Exception => error
      puts error.inspect
    ensure
      session.release if session
      @started = false
    end
  end
end

# some links
# http://home.gna.org/xmpp4r/
# http://jabber4r.rubyforge.org/
# http://socket7.net/software/jabber-bot
