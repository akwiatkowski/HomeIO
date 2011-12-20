#!/usr/bin/ruby
#encoding: utf-8

# HomeIO - home control system.
# Copyright (C) 2011 Aleksander Kwiatkowski
#
# This file is part of HomeIO.
#
# HomeIO is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# HomeIO is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with HomeIO.  If not, see <http://www.gnu.org/licenses/>.

require 'zlib'
require 'socket'

# Communication protocol for easy sending ruby objects via TCP socket.

class TcpCommProtocol
  # TCP port for communication
  attr_reader :port

  # Max command size which can server get
  MAX_COMMAND_SIZE = 1024

  # Max write frame size
  MAX_WRITE_FRAME_SIZE = 16384
  
  # Send command to server, receive reply
  #
  # :call-seq:
  #   TcpCommProtocol.send_to_server( comm, port ) => send to localhost
  #   TcpCommProtocol.send_to_server( comm, port, server )
  def self.send_to_server(comm, port, server = "localhost")
    stream_sock = TCPSocket.new(server, port)
    stream_sock.puts(comm_encode(comm))
    resp = comm_decode(stream_sock.recv(MAX_WRITE_FRAME_SIZE))
    stream_sock.close

    return resp
  end

  # Send command to server, receive reply
  #
  # :call-seq:
  #   send_to_server( TcpTask command, port ) => send to localhost
  #   send_to_server( TcpTask command, port, server )
  def send_to_server(comm, port, server = "localhost")
    self.class.send_to_server(comm, port, server)
  end

  private

  # Encode message
  def self.comm_encode(obj)
    return Zlib::Deflate.deflate(Marshal.dump(obj), 9)
  end

  # Decode message
  def self.comm_decode(obj)
    return Marshal.load(Zlib::Inflate.inflate(obj))
  end

  # Encode message
  def comm_encode(obj)
    return self.class.comm_encode(obj)
  end

  # Decode message
  def comm_decode(obj)
    return self.class.comm_decode(obj)
  end

end
