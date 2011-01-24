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
require "jabber4r/jabber4r"

# ugly fix for rexml in ruby 1.9, yuck!
require './lib/plugins/im/bots/adds/jabber4r_ugly_fix.rb'

# Works somehow at 1.9, better not use this
# Code for deletion/rewrite or wait to library fixes

class Jabber4rBot < ImBotAbstract
  include Singleton

  # Connect to server
  def initialize
    super
  end

  private

  def _start
    @login = @config[:login]
    @password = @config[:password]
    @started = false

    #Thread.abort_on_exception = true
    #Thread.new{
    bot_loop
    #bot_thread
    #}
  end

  def bot_loop
    loop do
      begin
        bot_thread
      rescue
      end
      sleep(5)
    end
  end

  def bot_thread
    begin
      @started = true
      session = Jabber::Session.bind("#{@login}/homeio", @password)

      #puts 1
      #session.connection.poll
      #puts 2

      Thread.abort_on_exception=true
      my_thread = Thread.current
      mlid = session.add_message_listener do |message|

        # respond only for non blank messages
        if not message.body.to_s == ''
          begin
            response = PROCESSOR.process_command( message.body, message.from )
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
