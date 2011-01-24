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


# Klasa określająca protokół przesyłania, port oraz kodowanie

require 'zlib'
require 'socket'


class Comm
  attr_reader :port
  
  # maksymalny rozmiar polecenia jakie dostaje serwer, zakodowana
  MAX_COMMAND_SIZE = 200

  # rozmiar pojedyńczej ramki jaka jest wysyłana i odbierana
  #MAX_FRAME_SIZE = 4096

  # rozmiar ramki przeznaczonej do wysyłu
  MAX_WRITE_FRAME_SIZE = 16384



  # Wyślij polecenie do serwera
  def self.send_to_server( comm, port )
    stream_sock = TCPSocket.new( "localhost", port )
    stream_sock.puts( comm_encode( comm ) )
    resp = comm_decode( stream_sock.recv( MAX_WRITE_FRAME_SIZE ) )
    stream_sock.close

    return resp
  end

  # Wyślij polecenie do serwera
  def send_to_server( comm, port )
    self.class.send_to_server( comm, port )
  end

  private

  # Metody styczny i instancyjne, statyczne do odbioru aby nie było konieczne tworzenie instancji
  # aby można było utworzyć instancje modelu korzystając z wzorca Fabryka

  # Przygotowanie do przesłania
  def self.comm_encode( obj )
    return Zlib::Deflate.deflate( Marshal.dump( obj ), 9 )
  end

  # Przetworzenie przesłanego obiektu
  def self.comm_decode( obj )
    return Marshal.load( Zlib::Inflate.inflate( obj ) )
  end

  # Metody instancyjne
  def comm_encode( obj )
    return self.class.comm_encode( obj )
  end
  
  def comm_decode( obj )
    return self.class.comm_decode( obj )
  end

  


end
