require './lib/supervisor/supervisor.rb'
require './lib/supervisor/supervisor_client.rb'
require 'test/unit'

class TestSupervisor < Test::Unit::TestCase

  def test_basic
    start_sv

    # ping
    assert_equal :ok, SupervisorClient.new.send_to_server(:ping)

    command = {:command => :fetch_metar }
    puts command.inspect
    result = SupervisorClient.new.send_to_server( command )
    puts result.inspect

    sleep 5

  end

  private

  # Start server thread
  def start_sv
    Thread.abort_on_exception = true
    Thread.new{
      Supervisor.instance
      loop do
        sleep 10
      end
    }
  end

end

