require 'singleton'

require './lib/supervisor/supervisor_queue.rb'
require './lib/supervisor/supervisor_server.rb'
require './lib/utils/config_loader.rb'

require './lib/metar_logger.rb'
require './lib/weather_ripper.rb'

# Supervisor which run taks for remote command
# Tasks are performed in queue

# Commands:
# :ping => :ok - used for testing
# {:command => :fetch_weather, :id => <random> } - start weather ripper
# {:command => :fetch_metar, :id => <random> } - start metar ripper

# Commands are defined in 'supervisor_queue.rb'

class Supervisor
  include Singleton

  attr_reader :components

  # Start TCP server
  def initialize

    self.class.reload_config

    # queue commands
    mq = SupervisorQueue.new
    mq.start

    # uses queue to process comands
    ms = SupervisorServer.new( mq, Supervisor.port )
    ms.start

    Thread.abort_on_exception = true

    puts "Supervisor started"

    loop do
      sleep( 30 )
    end

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

    @init_time = Time.now
  end

  def self.reload_config
    @@config = ConfigLoader.instance.config( self.to_s )
  end

end
