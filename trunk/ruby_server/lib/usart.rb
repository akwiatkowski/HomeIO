require 'singleton'
# strategy for retrieving values online/offline
require './lib/usart_offline.rb'
require './lib/usart_online.rb'

# Singleton for communicating via RS-232
class Usart
  include Singleton


  def initialize
    @@config = ConfigLoader.instance.config( self.class )
    @@ONLINE = @@config[:online]
    
    if @@ONLINE == true
      @@retrieve = UsartOnline.instance
      @@type = :online
    else
      @@retrieve = UsartOffline.instance
      @@type = :offline
    end
  end

  def type
    return @@type
  end

  # Return true if online, so ex. DbStore can choose DB
  def is_online?
    return @@ONLINE
  end

  # Fetch from uC or use simulator
  def retrieve( meas )
    # fetch value
    return @@retrieve.retrieve( meas )
  end

	
end