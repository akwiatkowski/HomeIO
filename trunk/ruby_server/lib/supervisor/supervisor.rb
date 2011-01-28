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


require 'singleton'

require './lib/supervisor/supervisor_queue.rb'
require './lib/supervisor/supervisor_server.rb'
require './lib/utils/config_loader.rb'

require './lib/metar_logger.rb'
require './lib/weather_ripper.rb'
require './lib/extractors/extractor.rb'
require './lib/comms/im_command_resolver.rb'

# Supervisor which run taks for remote command
# Tasks are performed in queue

# Commands:
#
# 1. Ping - test if server is running ok
# 2. Test - onother type of test
#    Input: {:command=>:test, :now=>true}
#    Output: {:command=>{:command=>:test, :now=>true}, :id=>90986760, :status=>:sent, :response=>{:test=>:ok}, :process_time=>3.719329833984375e-05}
#
# :ping => :ok - used for testing
# {:command => :fetch_weather, :id => <random> } - start weather ripper
# {:command => :fetch_metar, :id => <random> } - start metar ripper

# Commands are defined in 'supervisor_queue.rb'

class Supervisor
  include Singleton

  attr_reader :components

  # Prepare TCP server
  def initialize
    self.class.reload_config
    init
  end

  # Start supervisor
  # Components need to be initialized before starting supervisor
  def start
    # queue commands
    @mq = SupervisorQueue.new
    @mq.start

    # uses queue to process comands
    @ms = SupervisorServer.new( @mq, Supervisor.port )
    @ms.start

    Thread.abort_on_exception = true

    puts "Supervisor started"

    # TODO remove from config
    #if @@config[:start_im] == true
    #  # start IM botsbot gg
    #  sleep( 1 )
    #
    #  require './lib/plugins/im/im_bots.rb'
    #  im = ImBots.instance
    #  im.start
    #end

    loop do
      sleep( 30 )
    end
  end

  # Get queue
  def get_queue
    @mq.get_queue
  end

  def self.port
    reload_config unless defined? @@config
    return @@config[:tcp_port]
  end

  private

  # Load all components
  def init
    @components = Hash.new
    @components[ :MetarLogger ] = MetarLogger.instance
    @components[ :WeatherRipper ] = WeatherRipper.instance
    @components[ :Extractor ] = Extractor.instance
    @components[ :ImCommandResolver ] = ImCommandResolver.instance

    @init_time = Time.now
  end

  def self.reload_config
    @@config = ConfigLoader.instance.config( self.to_s )
  end

end
