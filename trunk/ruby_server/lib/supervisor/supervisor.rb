require './lib/supervisor/supervisor_queue.rb'
require './lib/supervisor/supervisor_server.rb'
require './lib/utils/config_loader.rb'

# Supervisor which run taks for remote command
# Tasks are performed in queue

class Supervisor

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
  end

  def self.reload_config
    @@config = ConfigLoader.instance.config( self.to_s )
  end

end
