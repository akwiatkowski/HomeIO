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

# TCP remote command server

class CommServer < Comm
  
  # Set up server
  #
  # +queue_processor+ - qeueue manager object 
  # +port+ - port
  def initialize( queue_processor, port )

    @queue_processor = queue_processor
    @port = port

  end
  
  # Start thread
  def start
    return Thread.new{ start_server }
  end

  private

  # Start TCP server
  def start_server

    dts = TCPServer.new('localhost', @port )
    puts "...TCP server started at port #{@port}"

    loop do
			Thread.start( dts.accept ) do |s|

        # command receved
        command = comm_decode( s.recv( MAX_COMMAND_SIZE ) )

        # add to queue
        response = @queue_processor.process_server_command( command )

        # reply response
        s.write( comm_encode( response) )

        # say goodbye
        s.close

			end
		end

  end

end
