require './lib/storage/storage.rb'
require 'test/unit'

class TestDbActiveRecord < Test::Unit::TestCase

  def test_basic
    StorageActiveRecord.instance
  end

end

