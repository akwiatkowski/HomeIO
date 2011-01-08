require './lib/supervisor/comm_queue.rb'

# Zajmie się przetwarzaniem poleceń dla serwera METAR które dostanie przez TCP

class SupervisorQueue < CommQueue

  private

  # Uruchamia przetwarzanie polecenia
  # po wykonaniu należy odpowiedź przechowywać w [:response]
  # nie trzeba zmieniać statusu zadania, jest to wykonywane gdzie indziej
  def process( command_enc )

    # do obliczania czasu przetwarzania
    start_time = Time.now.to_f
    command_enc.set_in_proccess!

    # processing
    command_enc[:status] = :processing

    # właściwie w tym miejsu jest polecenie wysłane z serwera
    command = command_enc[:command]


    result = case command[:command]
    when :fetch_weather then Supervisor.instance.components[:WeatherRipper].start
    when :fetch_metar then Supervisor.instance.components[:MetarLogger].start
    when :test then {:test => :ok}
    # DEV
    when :list_components then {:components => Supervisor.instance.components.keys, :status => :ok}
    else :wrong_command
    end

    command_enc[:response] = result
    command_enc[:process_time] = Time.now.to_f - start_time
    command_enc.set_done!
  end

end
