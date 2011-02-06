require 'lib/communication/task_server/tcp_comm_task_server'
require 'test/unit'

class TestTaskQueue < Test::Unit::TestCase
  PORT = 12365

  def test_simple
    t = TcpCommTaskServer.new(PORT)
    t.start

    sleep 0.5

    task = TcpTask.factory({:command => :test})
    res = TcpCommProtocol.send_to_server(task, PORT)
    puts res.inspect

    loop do
      sleep 1
    end

  end


end