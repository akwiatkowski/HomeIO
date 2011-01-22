require './lib/supervisor/comm.rb'
require './lib/supervisor/task.rb'
require './lib/utils/config_loader.rb'

class SupervisorClient < Comm
  
  # checks if task was finished every this seconds
  CHECK_EXEC_END_INTERVAL = 1

  # Send command to server
  def send_to_server( comm )
    task = Task.factory( comm )
    return super( task, SupervisorClient.port )
  end

  # Wait for finishing of execution of task
  # *response_task* - task returned by server as notice of added task into queue
  def self.wait_for_task( response_task )
    command = {:command => :fetch, :params => {:id => response_task.fetch_id} }

    while true
      res = SupervisorClient.new.send_to_server( command )
      if res.fetch_is_ready?
        return res
      end
      sleep( CHECK_EXEC_END_INTERVAL )
    end
  end

  private

  def self.port
    return @@tcp_port if defined? @@tcp_port
    return @@tcp_port = ConfigLoader.instance.config( 'Supervisor' )[:tcp_port]
  end

end
