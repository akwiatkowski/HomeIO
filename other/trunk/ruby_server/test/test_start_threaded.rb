require File.join Dir.pwd, 'lib/utils/start_threaded'
require 'test/unit'

class TestStartThreaded < Test::Unit::TestCase

  # Test exception invulnerability 
  def not_use_test_exception_security
    StartThreaded.start_threaded(2, self) do
      puts Time.now
      puts "Im alive!"
      sleep 10
      1/0
    end
  end

  def test_another
    StartThreaded.start_threaded(5, self) do
      puts "A* 5 s interval                  #{Time.now}"
      sleep 6
      puts "A* 5 s interval (6sec later)     #{Time.now}"
    end

    StartThreaded.start_threaded(8, self) do
      puts "B* 9 s interval                  #{Time.now}"
    end

    StartThreaded.start_threaded(2, self) do
      puts "C* 2 s interval                  #{Time.now}"
      sleep 11
      puts "C* 2 s interval (11sec later)     #{Time.now}"
    end

  end

end

