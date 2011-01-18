#!/usr/bin/ruby1.9.1
#encoding: utf-8

require './lib/plugins/im/bots/im_bot_abstract.rb'
require 'gg'
require 'iconv'

# Gadu-gadu bot

class GaduBot < ImBotAbstract
  include Singleton

  # Connect to server
  def initialize
    super
  end

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



  private

  # Start bot code
  def _start
    #@iconv = Iconv.new('ISO-8859-2','UTF-8')
    @iconv = Iconv.new('CP1250','UTF-8')

    puts "#{@config[:gg]}, #{@config[:password]}, #{@config[:server]}"
    @g = GG.new(@config[:gg], @config[:password], {:server => @config[:server]})

    # startup status
    # @g.status( STATUS_AVAIL, "HomeIO", false )
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
            response = PROCESSOR.process_command( msg, "gg:#{uin.to_s}" )
            # add to contact list
            @g.add( uin )
          rescue => e
            log_error( self, e )
            puts e.inspect
            puts e.backtrace
            response = 'Error'
          end

          # gg does not use utf-8, i'm shocked!
          response = @iconv.iconv( response )

          @g.msg(uin, response)
          
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
