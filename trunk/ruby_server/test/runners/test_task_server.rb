require 'lib/communication/task_server/tcp_comm_task_server'
require 'lib/communication/task_server/tcp_comm_task_client'
require 'test/unit'

class TestTaskServer < Test::Unit::TestCase
  def test_simple
    t = TcpCommTaskServer.new
    t.start

    sleep 0.2

    task = TcpTask.factory({ :command => :help })
    res = TcpCommTaskClient.instance.send_to_server(task)
    puts res.inspect
  end


end