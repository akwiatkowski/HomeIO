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

    # processing
    command_enc[:status] = :processing

    # właściwie w tym miejsu jest polecenie wysłane z serwera
    command = command_enc[:command]

    result = case command[:command]
    when :ping then :ok
    else :wrong_command
    end

    command_enc[:response] = result
    command_enc[:process_time] = Time.now.to_f - start_time
    command_enc[:status] = :done
  end

end
