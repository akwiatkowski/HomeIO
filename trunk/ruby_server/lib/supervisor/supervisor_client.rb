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


require './lib/supervisor/comm.rb'
require './lib/supervisor/task.rb'
require './lib/utils/config_loader.rb'

class SupervisorClient < Comm
  
  # checks if task was finished every this seconds
  CHECK_EXEC_END_INTERVAL = 1

  # Simple send command to server
  def send_to_server( comm )
    self.class.send_to_server( comm )
  end

  # Simple send command to server
  def self.send_to_server( comm )
    task = Task.factory( comm )
    return super( task, SupervisorClient.port )
  end

  # Send command to server, choose to wait or not
  def self.send_to_server_uni( comm, wait = true )
    if true == wait
      return send_to_server_and_wait( comm )
    else
      return send_to_server_non_wait( comm )
    end
  end

  # Send command to server, non wait
  def self.send_to_server_non_wait( comm )
    return send_to_server( comm.merge({:now => true}) )
  end

  # Send command to server, and wait
  def self.send_to_server_and_wait( comm )
    res = send_to_server( comm )
    last_response = SupervisorClient.wait_for_task( res )
    return last_response
  end

  # Get tasks list
  def self.get_queue
    res = send_to_server({
        :command => :fetch_queue,
        :now => true
      })
    return res
  end

  # Wait for finishing of execution of task
  # *response_task* - task returned by server as notice of added task into queue
  def self.wait_for_task( response_task )
    command = {:command => :fetch, :params => {:id => response_task.fetch_id} }

    while true
      res = SupervisorClient.new.send_to_server( command )
      if res.fetch_is_ready?
        return res
      end
      sleep( CHECK_EXEC_END_INTERVAL )
    end
  end

  private

  def self.port
    return @@tcp_port if defined? @@tcp_port
    return @@tcp_port = ConfigLoader.instance.config( 'Supervisor' )[:tcp_port]
  end

end
