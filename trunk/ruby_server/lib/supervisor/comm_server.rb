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
