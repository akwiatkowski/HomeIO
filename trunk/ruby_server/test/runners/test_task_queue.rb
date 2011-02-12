require 'lib/communication/task_server/tcp_comm_task_server'
require 'lib/communication/task_server/tcp_comm_task_client'
require 'test/unit'

class TestTaskQueue < Test::Unit::TestCase
  def test_simple
    t = TcpCommTaskServer.new
    t.start

    sleep 0.5

#    (1..5).each do |i|
#      #task = TcpTask.factory({:command => :test, :id => i})
#      task = TcpTask.factory({:command => :c})
#      res = TcpCommProtocol.send_to_server(task, t.port)
#      puts res.inspect
#    end

    task = TcpTask.factory({:command => :c})
    res = TcpCommTaskClient.instance.send_to_server(task)
    puts res.inspect

    res_b = TcpCommTaskClient.instance.wait_for_task(res)
    puts res_b.inspect

    #loop do
    #  sleep 1
    #end
    sleep 0.5

  end


end