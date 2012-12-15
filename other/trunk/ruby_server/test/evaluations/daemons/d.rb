require 'rubygems'        # if you use RubyGems
require 'daemons'

PWD = Dir.pwd
puts PWD

opts = {
  :dir_mode => :script,
  :dir => ".",
  :log_output => true
}

Daemons.run_proc('test',opts) do
  loop do
    puts PWD
    puts Time.now
    sleep(1)
    
    puts PWD
    puts Time.now
    sleep(1)
    
    a
  end
end