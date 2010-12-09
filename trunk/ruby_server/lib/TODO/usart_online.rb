require './lib/config_loader.rb'
require './lib/dev_info.rb'

require 'rubygems'
require 'serialport'
require 'serialport.so'
require 'monitor'
require 'singleton'
require 'logger'

# http://www.tutorialspoint.com/ruby/ruby_multithreading.htm

class UsartOnline
  include Singleton
  include MonitorMixin

  # Load config and open port
  def initialize
    @@config = ConfigLoader.instance.config( self.class )
    @@di = DevInfo.instance
    
    @@logger = Logger.new( @@config[:logger_path] )
    @@verbose = @@config[:verbose_communication]

    # delay before send to uC
    @@USART_SLEEP_PRE_SEND = @@config[:usart_sleep_pre_send]
    # delay after receive
    @@USART_SLEEP_POST_RECEIVE = @@config[:usart_sleep_post_receive]

    port_open
  end

  def retrieve( meas )

    synchronize do
      @@result = self.retrieve_from_uc
    end

    return @@result

    @mon.synchronize do
      begin
        #wysłanie poleceń do uC
        options[:commands].each do |command|
          flag = send_to_uc(command)
          return nil if flag == 1
        end

        #odbiór danych
        a = Array.new
        options[:bytes].times do
          a.push( receive_from_uc )
        end

        #zwrócenie tabeli lub liczby
        if options[:get_array] == true
          return a
        else
          @tmp = 0
          a.each do |raw|
            @tmp *= 256
            @tmp += raw
          end
          return @tmp
        end
      rescue
        #wystąpił wyjątek
        return nil
      end
    end

  end

  private

  # Send command and receive response
  def retrieve_from_uc( meas )
    begin

      # process to usart parameters
      u_par = meas.to_usart

      # send command
      u_par[:send].each do |sbyte|
        send_to_uc( sbyte )
      end

      # receive reply
      reply = Array.new

      u_par[:response_bytes].times do
        reply << receive_from_uc
      end

      # mix response if needed
      if u_par[:signle_value_response] == true
        raw_value = 0
        reply.each do |r|
          # next byte is younger
          raw_value *= 256
          # add current byte
          raw_value += r
        end
        return raw_value

      else
        return reply
        
      end


      

    rescue => e
      # when something goes wrong
      return {
        :status => :error,
        :exception => e,
        :online => true
      }
    end
  end

  # Open RS port
	def port_open
		@@sp = SerialPort.new(
      @@config[:port],
      @@config[:baud],
      @@config[:bits],
      @@config[:stop_port],
      @@config[:parity]
    )

    
    @@di[ self.class ][ :port_open_time ] = Time.now
	end

	# Close RS port
	def port_close
		@@di[ self.class ][ :port_close_time ] = Time.now
		@@sp.close
	end

  # Try to send byte to uC, return true if ok, return false when fail
  def send_to_uc( byte )
		@@logger.debug( "Sending #{byte.to_s}\n" ) if @@verbose

		begin
			sleep( @@USART_SLEEP_PRE_SEND ) #było 0.01
			@@sp.putc( byte )
      # increment stats
      @@di.inc( self.class, :send_success )

      return true

		rescue
			@@logger.error( "FAIL: Sending #{byte.to_s}\n" )
      @@logger.error( $! )
			@@logger.error( $!.backtrace )

      @@di.inc( self.class, :send_fail )

      return false
		end
  end

  # Receive one byte from uC
	def receive_from_uc
		@@logger.debug( "Receiving\n" ) if @@verbose

		@@byte = 0

		begin
			@@byte = @@sp.getc
			sleep( @@USART_SLEEP_POST_RECEIVE )

      # increment statistics
      @@di.inc( self.class, :receive_success )

		rescue
			@@logger.error( "FAIL: Receive\n" )
      @@logger.error( $! )
			@@logger.error( $!.backtrace )

      @@di.inc( self.class, :receive_fail )

      return nil
		end

		@@logger.debug( "Received #{@@byte.to_s}\n" ) if @@verbose

		return @@byte
	end

end
