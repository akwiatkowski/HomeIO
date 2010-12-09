# Module mixing code for simulation mode
module HomeIoMeasElementOnline

  # Create options for usart communication
  def to_usart

    # to send
    send_array = Array.new

    # unprocessed
    command_pre = @comm[:command]

    case command_pre.class
    when "String" then
      # convert string to array of fixnum
      command_pre.each_byte do |c|
        send_array << c
      end

    when "Fixnum" then
      # crate 1 element array
      send_array << command_pre

    when "Array" then
      # use this array
      send_array = command_pre

    end

    # response bytes
    response_bytes = @comm[:bytes]

    output = {
      :send => send_array,
      :response_bytes => response_bytes,
      :signle_value_response => @comm[:single_value_response]
    }

    return output

  end


end
