require 'test/unit'
require 'lib/communication/task_server/tcp_comm_task_server'
require 'lib/communication/task_server/tcp_comm_task_client'
require "lib/communication/db/extractor_active_record"

# Test TCP task server features

class TestTaskQueue < Test::Unit::TestCase

  def test_all
    t = TcpCommTaskServer.new
    t.start

    #_test_city_list_and_queue
    #_test_system_commands
    #_test_city_statistics
    _test_metars

    # servers live they own life
    StartThreaded.kill_all_sub_threads
  end

  def _test_city_list_and_queue
    task = TcpTask.factory({ :command => :c })
    res = TcpCommTaskClient.instance.send_to_server(task)
    assert_not_nil res.result_fetch_id, "Result fetch id unavailable, cannot fetch response"

    # waiting for reply
    res_cities = TcpCommTaskClient.instance.wait_for_task(res)
    # check reply
    assert_equal res_cities.response.size, ExtractorBasicObject.instance.get_cities.size
    assert_equal res_cities.response, ExtractorBasicObject.instance.get_cities
    # column names check
    assert_not_nil res_cities.response.first.keys & [:name]
    assert_not_nil res_cities.response.first.keys & [:country]
    assert_not_nil res_cities.response.first.keys & [:lat]
    assert_not_nil res_cities.response.first.keys & [:lon]
  end

  def _test_system_commands
    # queue test
    task = TcpTask.factory({ :command => :queue })
    queue = TcpCommTaskClient.instance.send_to_server(task).response
    assert_kind_of Array, queue
    #assert_equal 0, queue.size
    pre_queue_size = queue.size

    # commands list
    task = TcpTask.factory({ :command => :help })
    res = TcpCommTaskClient.instance.send_to_server(task)
    res = TcpCommTaskClient.instance.wait_for_task(res)

    assert_kind_of Array, res.response
    # test basic command in command list
    assert_equal 1, res.response.select { |q| (q[:command] & ["cities"]).size > 0 }.size
    assert_equal 1, res.response.select { |q| (q[:command] & ["help"]).size > 0 }.size
    assert_equal 1, res.response.select { |q| (q[:command] & ["queue"]).size > 0 }.size

    # check queue new size
    task = TcpTask.factory({ :command => :queue })
    queue = TcpCommTaskClient.instance.send_to_server(task).response
    assert_kind_of Array, queue
    assert_equal pre_queue_size + 1, queue.size
    assert_equal :help, queue.last.command
  end

  def _test_city_statistics
    # basic stats
    task = TcpTask.factory({ :command => :ci, :params => ['poz'] })
    res = TcpCommTaskClient.instance.send_to_server(task)
    res = TcpCommTaskClient.instance.wait_for_task(res)
    assert_kind_of Fixnum, res.response[:metar_count]
    assert_equal "Poznań", res.response[:city]
    assert_equal "Poland", res.response[:city_object][:country]

    # adv stats
    task = TcpTask.factory({ :command => :cix, :params => ['poz'] })
    res = TcpCommTaskClient.instance.send_to_server(task)
    res = TcpCommTaskClient.instance.wait_for_task(res)
    assert_kind_of Fixnum, res.response[:metar_count]
    assert_equal "Poznań", res.response[:city]
    assert_equal "Poland", res.response[:city_object][:country]
    puts res.to_yaml

  end

  def _test_metars
    # basic stats
    task = TcpTask.factory({ :command => :wmc, :params => ['poz'] })
    res = TcpCommTaskClient.instance.send_to_server(task)
    res = TcpCommTaskClient.instance.wait_for_task(res)

    assert_kind_of Hash, res.response
    assert_kind_of Hash, res.response[:city]
    assert_equal "EPPO", res.response[:city][:metar]
    assert_equal true, res.response[:city][:logged_metar]

    assert_kind_of Hash, res.response[:db]
    assert_kind_of Hash, res.response[:metar_code]
    assert_equal MetarCode.process_archived(
                   res.response[:db][:raw],
                   res.response[:db][:time_from].year,
                   res.response[:db][:time_from].month
                 ).to_hash, res.response[:metar_code]

  end


end

