require './lib/supervisor/supervisor.rb'
require './lib/supervisor/supervisor_client.rb'
require 'test/unit'

class TestSupervisor < Test::Unit::TestCase

  def test_basic
    SupervisorClient.new.send_to_server({:command => :ping})
  end

  private

  def start_sv
    Thread.new{ 
      Supervisor.new
    }
  end

end

