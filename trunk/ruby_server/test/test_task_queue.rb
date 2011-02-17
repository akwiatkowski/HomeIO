require 'test/unit'
require 'lib/communication/task_server/tcp_comm_task_server'
require 'lib/communication/task_server/tcp_comm_task_client'
require "lib/communication/db/extractor_active_record"

# TODO write test using wrong data, check stability

# Test TCP task server features

class TestTaskQueue < Test::Unit::TestCase

  def test_all
    t = TcpCommTaskServer.new
    t.start

    #_test_city_list_and_queue
    #_test_system_commands
    #_test_city_statistics
    #_test_metars
    _test_new

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
    # last metar
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


    # summary
    task = TcpTask.factory({ :command => :wms })
    res = TcpCommTaskClient.instance.send_to_server(task)
    res = TcpCommTaskClient.instance.wait_for_task(res)

    assert_kind_of Array, res.response
    assert_kind_of Hash, res.response.first
    assert_not_nil res.response.first[:raw]
    assert_not_nil res.response.first[:temperature]
    assert_not_nil res.response.first[:wind]
    assert_not_nil res.response.first[:time_from]
    # puts res.to_yaml


    # metars array
    task = TcpTask.factory({ :command => :wma, :params => ['EPPO', 1] })
    res = TcpCommTaskClient.instance.send_to_server(task)
    res = TcpCommTaskClient.instance.wait_for_task(res)

    # last metar
    task = TcpTask.factory({ :command => :wmc, :params => ['poz'] })
    last_metar = TcpCommTaskClient.instance.send_to_server(task)
    last_metar = TcpCommTaskClient.instance.wait_for_task(last_metar)

    #puts res.response.first.to_yaml, "****", last_metar.response.to_yaml
    assert_kind_of Array, res.response
    assert_equal 1, res.response.size
    # check if response from last metar array is equal to last metar
    assert_equal last_metar.response[:db], res.response.first


    # weather array
    task = TcpTask.factory({ :command => :wra, :params => ['poz', 1] })
    res = TcpCommTaskClient.instance.send_to_server(task)
    res = TcpCommTaskClient.instance.wait_for_task(res)

    assert_kind_of Array, res.response
    assert_equal 1, res.response.size

    task = TcpTask.factory({ :command => :wra, :params => ['poz', 5] })
    res = TcpCommTaskClient.instance.send_to_server(task)
    res = TcpCommTaskClient.instance.wait_for_task(res)

    assert_kind_of Array, res.response
    assert_equal 5, res.response.size
    #puts res.response.to_yaml


    # searching for metar
    # time of last metar
    task = TcpTask.factory({ :command => :wmc, :params => ['poz'] })
    res = TcpCommTaskClient.instance.send_to_server(task)
    res = TcpCommTaskClient.instance.wait_for_task(res)
    last_metar_time = res.response[:db][:time_from]

    # TODO possible time zone offset problems
    # search for metar
    task = TcpTask.factory({ :command => :wmsr, :params => ['poz', last_metar_time] })
    res = TcpCommTaskClient.instance.send_to_server(task)
    res = TcpCommTaskClient.instance.wait_for_task(res)
    puts res.response.to_yaml
    assert_equal last_metar_time, res.response[:time_from]

    # search for metar, string data
    task = TcpTask.factory({ :command => :wmsr, :params => ['poz', last_metar_time.to_date_human, last_metar_time.to_time_human] })
    res = TcpCommTaskClient.instance.send_to_server(task)
    res = TcpCommTaskClient.instance.wait_for_task(res)
    puts res.response.to_yaml
    assert_equal last_metar_time, res.response[:time_from]


    # search for weather
    task = TcpTask.factory({ :command => :wra, :params => ['poz', 1] })
    res = TcpCommTaskClient.instance.send_to_server(task)
    res = TcpCommTaskClient.instance.wait_for_task(res)
    last_weather_time = res.response.first[:time_from]
    last_weather = res.response.first

    task = TcpTask.factory({ :command => :wrsr, :params => ['poz', last_weather_time] })
    res = TcpCommTaskClient.instance.send_to_server(task)
    res = TcpCommTaskClient.instance.wait_for_task(res)

    assert_equal last_weather, res.response
  end

  def _test_new

  end


end

