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

require './lib/plugins/im/bots/im_bot_abstract.rb'
require 'gg'
# fix
require './lib/vendors/rgadu/lib/gg.rb'

require 'iconv'

# Gadu-gadu bot

class GaduBot < ImBotAbstract
  include Singleton

  # status types:
  # available
  STATUS_AVAIL = :avail

  # Change IM bot status
  #
  # type = :avail, :busy, :invisible, :notavail
  def change_status( type = STATUS_AVAIL, status = nil, only_friends = false )
    @status_type = type
    @status_status = status
    @status_friends = only_friends

    @g.status( @status_type, @status_status, @status_friends )
  end

  # Change IM bot status
  def change_status_only_text( status = nil )
    @status_status = status
    @g.status( @status_type, @status_status, @status_friends )
  end

  # Debug information
  def debug
    puts "GG"
    puts "plugin has nothing to add"
    puts "\n"
  end



  private

  # Start bot code
  def _start
    #@iconv = Iconv.new('ISO-8859-2','UTF-8')
    @iconv = Iconv.new('CP1250','UTF-8')

    # puts "#{@config[:gg]}, #{@config[:password]}, #{@config[:server]}"
    @g = GG.new(@config[:gg], @config[:password], {:server => @config[:server]})

    # startup status
    #@g.status( STATUS_AVAIL, "HomeIO", false )
    change_status( STATUS_AVAIL, "HomeIO", false )

    @g.on_msg do |uin, time, msg|
      # puts "#{uin} #{msg} #{time}"
      begin

        # only valid messages
        if not msg.nil?
          # that fix was needed :]
          msg.gsub!(/(\000.*)/,'')
          # puts msg.inspect
          # puts msg.to_s

          begin
            response = @processor.process_command( msg, "gg:#{uin.to_s}" )
            # add to contact list
            @g.add( uin )
          rescue => e
            log_error( self, e )
            show_error( e )
            response = 'Error'
          end

          # gg does not use utf-8, i'm shocked!
          response = @iconv.iconv( response )

          @g.msg(uin, response)
          
        end
      rescue => e
        # bigger error
        log_error( self, e )
        show_error( e )
      end
    end

  end
  
  # Stop bot
  def _stop
    @g.close
  end

end
