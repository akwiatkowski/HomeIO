require 'lib/action/action_manager'
require "lib/communication/io_comm/io_protocol"
require 'test/unit'

class TestActionManager < Test::Unit::TestCase

  def test_start_basic
    mf = ActionManager.instance
  end

end

