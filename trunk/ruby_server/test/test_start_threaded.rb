require 'lib/utils/start_threaded'
require 'test/unit'

class TestStartThreaded < Test::Unit::TestCase

  # Test exception invulnerability 
  def test_simple
    StartThreaded.start_threaded(2, self) do
      puts Time.now
      sleep 1
      1/0
    end
  end

  def test_another
    Thread.new do
      loop do
        puts 1
        sleep 0.5
      end
    end
  end

end

