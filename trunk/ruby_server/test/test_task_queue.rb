require 'test/unit'
require 'lib/communication/task_server/tcp_comm_task_server'
require 'lib/communication/task_server/tcp_comm_task_client'
require "lib/communication/db/extractor_active_record"

# Test TCP task server features

class TestTaskQueue < Test::Unit::TestCase

  def test_city_list_and_queue
    t = TcpCommTaskServer.new
    t.start

    sleep 0.2

    task = TcpTask.factory({:command => :c})
    res = TcpCommTaskClient.instance.send_to_server(task)
    assert_not_nil res.result_fetch_id, "Result fetch id unavailable, cannot fetch response"

    # waiting for reply
    res_cities = TcpCommTaskClient.instance.wait_for_task(res)
    # check reply
    assert_equal res_cities.response.size, ExtractorBasicObject.instance.get_cities.size
    assert_equal res_cities.response, ExtractorBasicObject.instance.get_cities
    # column names check
    assert_not_nil  res_cities.response.first.keys & [:name]
    assert_not_nil  res_cities.response.first.keys & [:country]
    assert_not_nil  res_cities.response.first.keys & [:lat]
    assert_not_nil  res_cities.response.first.keys & [:lon]

    # queue test
    task = TcpTask.factory({:command => :queue})
    res = TcpCommTaskClient.instance.send_to_server(task)
    assert_not_nil res.result_fetch_id, "Result fetch id unavailable, cannot fetch response"



    # servers live they own life
    StartThreaded.kill_all_sub_threads
  end


end