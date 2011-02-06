#!/usr/bin/ruby
#encoding: utf-8

# This file is part of HomeIO.
#
#    HomeIO is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    HomeIO is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

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
