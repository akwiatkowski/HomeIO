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

require 'rubygems'
require 'singleton'

require './lib/comms/im_command_resolver.rb'
require './lib/comms/im_processor.rb'
require './lib/utils/config_loader.rb'

# Abstract class to all IM comm. classes

class ImBotAbstract
  include Singleton

  # Processor class used for resolving commands
  attr_reader :processor

  # Processor can only be changed while bot is not running
  def processor=( pr )
    if false == @started_now
      @processor = pr
    end
  end

  # interval how ofthen check if bot is started
  BOT_CHECK_INTERVAL = 60

  # is bot enabled
  attr_reader :enabled

  # Load config and setup link to processor
  def initialize
    @config = ConfigLoader.instance.config( self.class )
    @enabled = @config[:enabled]

    # is started now
    @started_now = false
  end

  # Bot starter
  # Start only if enabled
  def start
    _start if true == @enabled
  end

  # Bot starter
  # Start only if enabled
  def start_with_wrong_safety
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
