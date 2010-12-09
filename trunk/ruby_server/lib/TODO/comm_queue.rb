require './lib/comm_queue_position.rb'

# Kolejka do zadań komunikacyjnych

class CommQueue

  # kolejka poleceń
  attr_reader :queue

  # czy jest uruchomione
  attr_reader :is_running

  def initialize
    @queue = Array.new
    @is_running = true
  end

  # Uruchamia
  def start
    Thread.new{ queue_loop}
  end

  # Decyduje co zrobić z poleceniem które odebrał serwer
  def process_server_command( command )

    # wysłanie do kolejki które....
    # albo zwracana odpowiedź
    
    # ping
    if command == :ping
      # czy serwer żyje
      return :ok
      
    elsif not command[:receive].nil? and not command[:id].nil?
      # pobierana jest odpowiedź
      return send_processed( command[:id] )

    elsif not command[:command].nil?
      # jest dodane do listy do przetworzenia
      return add_to_list( command )

    elsif not command[:receive_queue].nil?
      # zwraca kolejkę
      return @queue
      
    end
  end

  # Dodaje polecenie do listy i zwraca jego status (dodane) oraz id
  # w celu późniejszego pobrania wyniku lub statusu jego przetwarzania
  def add_to_list( command )
    h = Hash.new
    # polecenie które zostało przysłane
    h[:command] = command
    # identyfikator do wyszukiwania
    h[:id] = command.object_id
    # status
    h[:status] = :new

    # przetworzenie na obiekt zadania
    qp = CommQueuePosition.new( h )

    # gdy jest to zadanie pilne to wykonywane jest teraz i odpowiedź wysłana
    # od razu
    if command[:now] == true
      # od razu
      process( qp )
      return send_qp_response( qp )
    else
      # dodane do listy
      @queue << qp
      return {:status => :added, :id => h[:id]}
    end

    

    
  end

  # Wysłanie odpowiedzi przetworzonego polecenia
  def send_processed( id )

    # znalezienie polecenia
    qps = @queue.select{|q| q[:id] == id}

    # nie ma jednego takiego zadania na liście
    if not qps.size == 1
      return :not_on_queue
    end

    qp = qps.first

    # nie zostało wykonane
    if not qp.is_ready? == true
      return :not_ready
    end

    # gotowe, wysłanie odpowiedzi
    return send_qp_response( qp )
  end

  # Wysyła odpowiedź po przetworzonym zadaniu
  def send_qp_response( qp )
    response = qp[:response] # aby inny wątek nie skasował tego
    qp.set_sent!
    return {
      :status => :ok,
      :response => response
    }
  end

  private

  # Obsługuje przetwarzanie po kolei
  def queue_loop

    # pętla główna
    loop do

      # jeśli jest włączone to przetwarzaj kolejkę
      if @is_running == true

        # dla wszystkich elementów nowych kolejki włącza przetwarzanie
        @queue.select{|q| q.is_new? }.each do |q|
          # wykonaj
          process( q )
          # ustaw na wykonane
          q.set_done!
        end

        # usuwa wszystkie wysłane elementy
        @queue.delete_if{|q| q.is_sent? }


      end

      sleep( 0.5 )

    end

    
  end

  # Ustawia że polecenie jest wykonane
  def queue_position_done( q )
    q[:status] = :done
  end

end
