require './lib/supervisor/comm.rb'
require './lib/supervisor/comm_queue_task.rb'
require './lib/utils/config_loader.rb'

class SupervisorClient < Comm
  
  # checks if task was finished every this seconds
  CHECK_EXEC_END_INTERVAL = 1

  # Wyślij polecenie do serwera
  def send_to_server( comm )
    return super( comm, SupervisorClient.port )
  end

  # Wait for finishing of execution of task
  def self.wait_for_task( id )
    command = {:command => :fetch, :id => id }

    while true
      res = SupervisorClient.new.send_to_server( command )
      return res if res.finished?
      sleep( CHECK_EXEC_END_INTERVAL )
    end
  end

  private

  def self.port
    return @@tcp_port if defined? @@tcp_port
    return @@tcp_port = ConfigLoader.instance.config( 'Supervisor' )[:tcp_port]
  end

end
