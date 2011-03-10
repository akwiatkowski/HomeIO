require 'lib/action/action_manager'
require "lib/communication/io_comm/io_protocol"
require 'test/unit'

class TestActionManager < Test::Unit::TestCase

  def test_start_basic
    mf = ActionManager.instance
    puts mf.get_action_by_type('test_zero').execute
    puts mf.get_action_by_type('test_numbers').execute
    puts mf.get_action_by_type('start_total_brake').execute

  end

end

