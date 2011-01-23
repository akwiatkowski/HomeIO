require './lib/supervisor/supervisor.rb'
require './lib/supervisor/supervisor_client.rb'
require 'test/unit'

class TestSupervisor < Test::Unit::TestCase

  def test_basic
    start_sv

    # ping
    assert_equal :ok, SupervisorClient.send_to_server( Task.factory(:command => :ping) )

    # test immediate execution
    command = Task.factory({:command => :test, :now => true})
    response = SupervisorClient.send_to_server( command )
    # assert_equal :ok, response[:status]
    puts response.inspect
    assert_equal :ok, response.response

    # number of components
    command = Task.factory({:command => :list_components, :now => true})
    response = SupervisorClient.send_to_server( command )
    puts "components: #{response.inspect}"
    assert_equal :ok, response.response[:status]
    assert_kind_of Array, response.response[:components]

    sleep 0.5
  end

  def TODO_test_long_actions
    # start fetching metar
    #command = {:command => :fetch_metar }
    command = Task.factory({:command => :fetch_weather })
    result = SupervisorClient.send_to_server( command )
    # puts result.inspect
    id = result.fetch_id

    #waiting for ending
    command = Task.factory({:command => :fetch, :id => id })

    need_to_wait = true
    while need_to_wait
      res = SupervisorClient.send_to_server( command )
      SupervisorClient.wait_for_task( res )
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

