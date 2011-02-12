require "lib/communication/task_server/task_worker"
require "lib/communication/task_server/workers/tcp_standard_worker"

# Worker for HomeIO, process command in queue

class HomeIoTaskWorker < TaskWorker

  private

  # Process one task
  #
  # :call-seq:
  #   _process_task( TcpTask )
  def _process_task(q)
    # standard test command
    if q.command == :test
      q.response = r
      return q
    end

    # process command using standardized worker
    q.response = TcpStandardWorker.instance.process(q.command)
    return q

  end

end