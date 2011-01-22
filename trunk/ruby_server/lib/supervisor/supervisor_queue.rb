require './lib/supervisor/comm_queue.rb'

# Standard queue enhanced by HomeIO remote command proccesor

class SupervisorQueue < CommQueue

  private

  # Start processing task
  # After finish, result should be stored into :response key
  # Status changes are done elsewhere
  def process_task( task )
    task.set_in_proccess!
    command = task.command

    # running commans
    if task.type_proc?
      # run proc
      command.run_proc( Supervisor.instance )
    else
      # TODO rewrite to make response accesor private
      task.response = process_symbol( command )
    end

    task.set_done!
  end

  # Process command when it is send as symbol
  def process_symbol( command )
    return case command[:command]
    when :fetch_weather then Supervisor.instance.components[:WeatherRipper].start
    when :fetch_metar then Supervisor.instance.components[:MetarLogger].start
    when :process_metar_city then
      begin
        MetarMassProcessor.instance.process_all_for_city( command[:city] )
        {:status => :ok}
      rescue => e
        log_error( self, e )
        puts e.inspect
        puts e.backtrace
        return {:status => :failed}
      end
    when :test then {:test => :ok}
      # extracting data remotely
      #when :extract then Supervisor.instance.components[:Extractor].remote_command( command )
      # DEV
    when :list_components then {:components => Supervisor.instance.components.keys, :status => :ok}
    else :wrong_command
    end
  end

end
