#!/usr/bin/ruby -w

require 'socket'
require 'lib/metar_tools'
require 'lib/metar_server'
require 'lib/comm_queue_position'
require 'timeout'


class MetarTcpClient < Comm

  #def initialize( port = @@port)
	#def initialize( port = MetarServer::PORT )
	def initialize( port = MetarTools.load_config[:tcp_port] )
    @port = port
  end

  # Wysyłanie polecenia
  def send( comm )
    stream_sock = TCPSocket.new( "localhost", @port )
    stream_sock.puts( comm_encode( comm ) )
    status = comm_decode( stream_sock.recv( MAX_WRITE_FRAME_SIZE ) )
    stream_sock.close

    return status
  end

  def receive_queue
    send({:receive_queue => true})
  end

  def create_all_graphs( now = false)
    w = [
      :temperature,
      :visiblity,
      :wind,
      :pressure
    ]



    w.each do |ww|
      begin
        send({
            :command => :create_graph_all,
            :which => ww,
            :now => false,
            :options => {
              :time_range => :full_month
            }
          })
      rescue
      end
    end



  end

  def create_sample_graph
    w = [
      :temperature,
      #:visiblity,
      #:wind,
      :pressure
    ]
      
    w.each do |ww|
      send({
          :command => :create_graph,
          :city => "EPPO",
          #:city => "HECA",
          :year => 2009,
          :month => 12,
          #:month => 1,
          #:which => 
          :which => ww,
          :options => {
            :time_range => :full_month
          }

        })  
    end

  end

  def start_server
    send({
        :command => :start_server,
        :now => true
      })
  end

  def stop_server
    send({
        :command => :stop_server,
        :now => true
      })
  end

  def everything
    send({
        :command => :create_graph_everything
      })
  end

end

mtc = MetarTcpClient.new
#queue = mtc.receive_queue; puts queue.inspect

#queue = mtc.receive_queue; puts queue.inspect
#status = mtc.stop_server; puts status.inspect

# przykładowy wykres
#status = mtc.create_sample_graph; puts status.inspect

# wszystkie wykresy
#status = mtc.create_all_graphs; puts status.inspect

mtc.everything