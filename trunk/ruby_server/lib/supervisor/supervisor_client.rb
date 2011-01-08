require './lib/supervisor/comm.rb'
require './lib/supervisor/comm_queue_task.rb'
require './lib/utils/config_loader.rb'

class SupervisorClient < Comm
  # Wyślij polecenie do serwera
  def send_to_server( comm )
    return super( comm, SupervisorClient.port )
  end

  private

  def self.port
    return @@tcp_port if defined? @@tcp_port
    return @@tcp_port = ConfigLoader.instance.config( 'Supervisor' )[:tcp_port]
  end

end
