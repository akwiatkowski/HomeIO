require "lib/utils/start_threaded"
require "lib/communication/task_server/tcp_task"
require "lib/utils/adv_log"

# Worker search for new commands and execute them

class TaskWorker

  def initialize(queue)
    @queue = queue
    @mutex = Mutex.new
  end

  def start
    puts "Worker started"
    StartThreaded.start_threaded(2, self) do
      start_searching
    end
  end

  private

  # Search all queue for new task
  def start_searching
    #puts "#{self.class.to_s} Searching queue"
    t = nil
    @mutex.synchronize do
      # select all new
      qs = @queue.select { |q| q.is_new? }
      # select first on queue to run
      if qs.size > 0
        t = qs.first
        t.set_in_process!
      end
    end
    # process outside mutes
    process_task(t) unless t.nil?
  end

# Wrapper task processor
  def process_task(q)
    begin
      _process_task(q)
      q.set_done!
      #puts "Done"
    rescue => e
      q.set_error!(e.to_s)
      log_error(self, e)
      show_error(e)
    end
  end

# Method to override for executing task
  def _process_task(q)
  end

end