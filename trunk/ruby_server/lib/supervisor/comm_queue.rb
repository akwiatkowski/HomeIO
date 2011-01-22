require './lib/supervisor/comm_queue_task.rb'

# Communication commands queue

class CommQueue

  # check queue every this seconds, interval between tasks
  QUEUE_LOOP_INTERVAL = 1 # 0.5

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

  # Decide what do with received command:
  # :ping - reply now
  # :fetch - fetch response of command
  def process_server_command( command )

    puts @queue.inspect

    # ping
    if command == :ping
      # server is alive
      return :ok

      # fetch response
    elsif command[:command] == :fetch #and not command[:id].nil?
      # fetch response from queue
      if command[:id].nil?
        return {:result => :failed, :reason => :no_id}
      else
        return fetch_task_by_id( command[:id] )
      end

    elsif not command[:command].nil?
      # jest dodane do listy do przetworzenia
      return add_to_list( command )

    elsif not command[:receive_queue].nil?
      # zwraca kolejkę
      return @queue
      
    end
  end

  # Add command to list as task, return it status and id to fetch later response
  # Or Process hurry task now
  def add_to_list( command )
    # clean old items from list
    clean_list

    # creating task
    h = Hash.new
    # received command
    h[:command] = command
    # id for fetching
    h[:id] = command.object_id
    # przetworzenie na obiekt zadania
    task = CommQueueTask.new( h )

    # check if task needs processing now, hurry
    if task.process_now?
      # do it now
      process_task( task )
      return task.to_h_for_sending
    else
      # add to list
      @queue << task
      return {:status => :added, :id => task.fetch_id}
    end
  end

  # Check if some tasks should be deleted from list
  def clean_list
    @queue.delete_if{|q|
      q.old?
    }
  end


  # Wysłanie odpowiedzi przetworzonego polecenia
  def fetch_task_by_id( id )
    # delete old
    clean_list

    # select
    tasks = @queue.select{|q| q.fetch_id == id}

    # checking is in queue
    if not tasks.size == 1
      return :not_in_queue
    else
      return tasks.first.to_h_for_sending
    end
  end

  private

  # Mantain processing queue
  def queue_loop
    # main loop
    loop do
      # flag for start/stop
      if @is_running == true
        task = queue_first_new
        if not task.nil?
          # process it
          puts task.inspect
          process_task( task )
        end
      end

      sleep( QUEUE_LOOP_INTERVAL )
    end
  end

  # Find first new
  def queue_first_new
    @queue.each do |q|
      if q.is_new?
        return q
      end
    end
    return nil
  end

   # Another method for possible uniq id generation
  def self.generate_id
    str = Time.now.to_s + Time.now.to_f.to_s + rand(12345).to_s
    hash = Digest::SHA2.new << str
    return hash.to_s
  end

end
