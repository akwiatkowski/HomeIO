require './lib/supervisor/supervisor.rb'
require './lib/supervisor/supervisor_client.rb'
require 'test/unit'

class TestSupervisor < Test::Unit::TestCase

  def test_basic
    start_sv

    # ping
    assert_equal :ok, SupervisorClient.new.send_to_server(:ping)

    # test immediate execution
    command = {:command => :test, :now => true}
    response = SupervisorClient.new.send_to_server( command )
    # assert_equal :ok, response[:status]
    puts response.inspect
    assert_equal :ok, response[:response][:test]

    # number of components
    command = {:command => :list_components, :now => true}
    response = SupervisorClient.new.send_to_server( command )
    puts "components: #{response.inspect}"
    assert_equal :ok, response[:response][:status]
    assert_kind_of Array, response[:response][:components]

    sleep 0.5
  end

  def a_test_long_actions
    # start fetching metar
    #command = {:command => :fetch_metar }
    command = {:command => :fetch_weather }
    result = SupervisorClient.new.send_to_server( command )
    # puts result.inspect
    id = result[:id]

    #waiting for ending
    command = {:command => :fetch, :id => id }

    need_to_wait = true
    while need_to_wait
      res = SupervisorClient.new.send_to_server( command )
      # something like do-while
      need_to_wait = ( res != :not_in_queue and res[:status] != :done )

      if need_to_wait
        puts "... test"
      else
        puts res.inspect
      end

      sleep(5)
    end

  end

  private

  # Start server thread
  def start_sv
    Thread.abort_on_exception = true
    Thread.new{
      s = Supervisor.instance
      s.start
      loop do
        sleep 10
      end
    }
    sleep 0.5
  end

end

