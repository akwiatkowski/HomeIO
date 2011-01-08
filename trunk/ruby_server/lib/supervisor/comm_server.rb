require './lib/supervisor/comm.rb'

class CommServer < Comm
  
  # Ustawia tylko serwer
  #
  # +queue_processor+ - obiekt zajmujący się kolejką
  # +port+ - port
  def initialize( queue_processor, port )

    @queue_processor = queue_processor
    @port = port

  end
  
  # Uruchamia wątek
  def start
    return Thread.new{ start_server }
  end

  private

  # Uruchamia serwer TCP
  def start_server

    dts = TCPServer.new('localhost', @port )
    puts "...TCP server started at port #{@port}"

    loop do
			Thread.start( dts.accept ) do |s|

        # odebranie polecenia
        command = comm_decode( s.recv( MAX_COMMAND_SIZE ) )

        # co zrobić z poleceniem decyduje kolejka
        response = @queue_processor.process_server_command( command )

        # odesłąnie odpowiedzi od kolejki
        s.write( comm_encode( response) )

        s.close


			end
		end

  end

end
