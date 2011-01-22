require 'singleton'
require './lib/supervisor/supervisor_client.rb'

# When used extraction is made via TCP socket as a task
# It wait in queue
#
# NOT READY - some Extractor methods return AR objects
# so I don't want to change too much
#
# Other thing, calling methods send by network - not so safe

class TcpClientExtractor
  include Singleton

  def initialize
    @sc = SupervisorClient.new
  end

  #
  def method_missing(method, *arg)
    command = {
      # use extractor
      :command => :extract,
      :method => method,
      :args => arg
    }
    added_res = @sc.send_to_server( command )

    # waiting for response
    res = SupervisorClient.wait_for_task( added_res[:id] )

    return res
  end
  
end
