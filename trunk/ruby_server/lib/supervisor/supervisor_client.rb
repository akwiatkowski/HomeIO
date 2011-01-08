require './lib/supervisor/comm.rb'

class SupervisorClient < Comm
  # Wyślij polecenie do serwera
  def send_to_server( comm )
    return super( comm, Supervisor.port )
  end
end
