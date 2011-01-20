#!/usr/bin/ruby1.9.1
#encoding: utf-8

require 'rubygems'
require 'singleton'

require './lib/plugins/im/im_command_resolver.rb'
require './lib/plugins/im/im_processor.rb'
require './lib/utils/config_loader.rb'

# Abstract class to all IM comm. classes

class ImBotAbstract
  include Singleton

  # processor class used for resolving commands
  PROCESSOR = ImCommandResolver

  # interval how ofthen check if bot is started
  BOT_CHECK_INTERVAL = 60

  # is bot enabled
  attr_reader :enabled

  # Load config
  def initialize
    @config = ConfigLoader.instance.config( self.class )
    @enabled = @config[:enabled]

    # is started now
    @started_now = false
  end

  # Bot starter
  # Start only if enabled
  def start_old
    _start if true == @enabled
  end

  # Bot starter
  # Start only if enabled
  def start
    Thread.abort_on_exception = true
    Thread.new do
      loop do
        begin
          # start when enabled and not started now
          if true == @enabled and false == @started_now
            _start
            @started_now = true
          end
        rescue => e
          # something went wrong - start again
          @started_now = false
          puts e.inspect
          puts e.backtrace
        end
        sleep( BOT_CHECK_INTERVAL )
      end
    end
  end

  # Test method for checking server reliability
  def _dev_crash
    crach_the_server
  end

  # Special secret crash command
  def _dev_crash_command( command )
    if not command.index("ZXCasd").nil?
      crach_the_server
    end
  end


  private



end
