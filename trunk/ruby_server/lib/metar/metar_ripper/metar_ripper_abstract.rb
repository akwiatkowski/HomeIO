require 'open-uri'
require './lib/utils/adv_log.rb'

class MetarRipperAbstract

  attr_reader :exception

  def fetch( city )

    u = url( city )

    begin
      page = open( u )
      body = page.read
      page.close

      metar = process( body )
      @exception = nil

    rescue => e
      @exception = e
      log_error( self, e )
      metar = nil
    rescue Timeout::Error => e
      # in case of timeouts do nothing
      metar = nil
    end

		#puts metar.inspect
		return metar
  end


  # Methods for override
  # URL for downlaoding
  def url( city )
    raise 'Method not implemented'
  end

  # Process body to metar string
  def process( body )
    raise 'Method not implemented'
  end
end
