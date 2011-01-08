require './lib/supervisor/comm_queue_task.rb'

# Communication commands queue

class CommQueue

  # check queue every this seconds, interval between tasks
  QUEUE_LOOP_INTERVAL = 0.5

  # the queue
  attr_reader :queue

  # Flag is queue active
  attr_reader :is_running

  def is_running?
    return self.is_running
  end

  def initialize
    @queue = Array.new
    @is_running = true
  end

  # Uruchamia
  def start
    Thread.abort_on_exception = true
    Thread.new{ queue_loop }
  end

  # Decide what do with received command
  def process_server_command( command )

    # ping
    if command == :ping
      # server is alive
      return :ok
      
    elsif command[:command] == :fetch #and not command[:id].nil?
      # fetch response from queue
      if command[:id].nil?
        return {:result => :failed, :reason => :no_id}
      else
        return send_task( command[:id] )
      end

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
    #h[:id] = self.class.generate_id
    # status
    h[:status] = :new

    # przetworzenie na obiekt zadania
    qp = CommQueueTask.new( h )

    # gdy jest to zadanie pilne to wykonywane jest teraz i odpowiedź wysłana
    # od razu
    if command[:now] == true
      # od razu
      process( qp )
      return generate_qp_response( qp )
    else
      # dodane do listy
      @queue << qp
      return {:status => :added, :id => h[:id]}
    end

    

    
  end

  # Wysłanie odpowiedzi przetworzonego polecenia
  def send_task( id )

    # znalezienie polecenia
    qps = @queue.select{|q| q[:id] == id}

    # nie ma jednego takiego zadania na liście
    if not qps.size == 1
      return :not_in_queue
    end

    qp = qps.first

    # gotowe, wysłanie odpowiedzi
    return generate_qp_response( qp )
  end

  # Generate response after finishing task
  def generate_qp_response( qp )
    qp.set_sent! if qp.is_ready?
    return qp
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

      sleep( QUEUE_LOOP_INTERVAL )

    end
    
  end

  # Ustawia że polecenie jest wykonane
  def queue_position_done( q )
    q[:status] = :done
  end

  def self.generate_id
    str = Time.now.to_s + Time.now.to_f.to_s + rand(12345).to_s
    hash = Digest::SHA2.new << str
    return hash.to_s
  end

end
