require 'lib/comm_queue'
require 'lib/metar_processor'

# Zajmie się przetwarzaniem poleceń dla serwera METAR które dostanie przez TCP

class MetarQueue < CommQueue

  # Ustawia ref. do serwera logującego
  def set_references( refs = {})
    @metar_logger = refs[:metar_logger]
  end

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

    when :receive_cities then MetarTools.log_cities #@metar_logger.cities
    when :receive_log_times then MetarTools.log_times_for_city( command[:city ])

    when :start_server then @metar_logger.start
    when :stop_server then @metar_logger.stop
    when :status_server then @metar_logger.status

    when :process then 
      MetarProcessor.process( command  )
    when :create_graph then 
      MetarProcessor.create_graph( command )
    when :create_graph_all then
      MetarProcessor.create_graph_all( command )

    when :create_graph_everything then 
      MetarProcessor.create_graph_everything( command )

    when :get_weather then
      MetarProcessor.get_weather( command )

    when :wind_turbine_energy then
      MetarProcessor.wind_turbine_energy( command )
    when :wind_turbine_energy_at then
      MetarProcessor.wind_turbine_energy_at( command )

    when :cities_statistics then
      MetarProcessor.cities_statistics( command )
    when :month_statistics then
      MetarProcessor.month_statistics( command )





    else :wrong_command
    end

    #puts command.inspect
    #command_enc[:response] = "KONIEC"
    command_enc[:response] = result

    command_enc[:process_time] = Time.now.to_f - start_time
    command_enc[:status] = :done

  end

end
