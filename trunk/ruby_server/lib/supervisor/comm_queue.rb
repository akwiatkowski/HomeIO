require './lib/supervisor/comm_queue_task.rb'
require './lib/supervisor/task.rb'

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
  #
  # Should return only Task objects
  def process_server_command( task )
    # is more standarized object than hash
    task = Task.factory( task )

    # ping
    if task.command == :ping
      # server is alive
      task.response = :ok
      return task

      # fetch response
    elsif task.command == :fetch
      id_task_to_fetch = task.params[:id]

      # fetch response from queue
      if id_task_to_fetch.nil?
        task.set_fetch_no_id!
        return task
      else
        # searching by id
        fetched_q_task = fetch_q_task_by_id( id_task_to_fetch )
        if fetched_q_task.nil?
          # not found
          task.set_fetch_not_found!
          return task

        elsif not fetched_q_task.finished?
          # task is not ready
          task.set_fetch_not_ready!
          return task

        else
          # found
          # mark that it will be that long awaited response
          fetched_q_task.task.set_fetch_ok!
          fetched_q_task.set_sent!
          return fetched_q_task.task
        end
      end

    elsif task.command == :fetch_queue
      # return queue's Tasks, not CommQueueTasks
      task.response = @queue.collect{|q| q.task }
      return task

    elsif not task.command.nil?
      # add to queue
      # if task is very hurry it will be processed now
      return add_task_to_queue( task )
      
    end
  end

  # Add command to list as task, return it status and id to fetch later response
  # Or Process hurry task now
  def add_task_to_queue( task )
    # clean old items from list
    clean_list

    q_task = CommQueueTask.new( task )

    # check if task needs processing now, hurry
    if q_task.process_now?
      # do it now
      process_q_task( q_task )
      q_task.set_sent!
      return q_task.task
    else
      # add to list
      # generate id, and change status
      q_task.added_on_queue!
      @queue << q_task
      return q_task.task
    end
  end

  # Check if some tasks should be deleted from list
  def clean_list
    @queue.delete_if{|q|
      q.old?
    }
  end


  # Wysłanie odpowiedzi przetworzonego polecenia
  def fetch_q_task_by_id( id )
    # delete old
    clean_list

    # select
    q_tasks = @queue.select{|q| q.fetch_id == id}

    # checking is in queue
    if not q_tasks.size == 1
      return nil
    else
      # sending task object, not only hash
      t = q_tasks.first
      return t
    end
  end

  private

  # Mantain processing queue
  def queue_loop
    # main loop
    loop do
      # flag for start/stop
      if @is_running == true
        q_task = find_first_new_q_task
        if not q_task.nil?
          # process it
          puts "Processing #{q_task.inspect}"
          process_q_task( q_task )
        end
      end

      sleep( QUEUE_LOOP_INTERVAL )
    end
  end

  # Find first new CommQueueTask
  def find_first_new_q_task
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
