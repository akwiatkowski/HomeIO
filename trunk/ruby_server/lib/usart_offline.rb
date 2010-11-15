require 'singleton'

# Simulates without real Usart (offline mode)
class UsartOffline
  include Singleton

  def retrieve( meas )
    raw_value = meas.offline_create_raw
    puts "USART_RETRIEVE #{raw_value}" # TODO DELETE
    return {
      :status => :ok,
      :raw => raw_value,
      :online => false
    }
  end
end
