require "lib/utils/start_threaded"

# Worker search for new commands

class TaskWorker

  def initialize( queue )
    @queue = queue
  end

  def start
    StartThreaded.start_threaded(1, self) do
      start_searching
    end
  end

  private

  def start_searching
    @queue.each do |q|
      puts q.command
    end
  end

end