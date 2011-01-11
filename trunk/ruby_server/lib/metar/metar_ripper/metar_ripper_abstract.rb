require 'open-uri'
require './lib/utils/adv_log.rb'

class MetarRipperAbstract

  attr_reader :exception

  # Show times of fetching website per provider and city
  SHOW_PROVIDERS_TIME_INFO = false

  # Fetch metar for city
  # *city* - city metar code, ex. EPPO
  def fetch( city )

    u = url( city )

    begin
      t = Time.now
      page = open( u )
      body = page.read
      page.close
      puts "#{self.class} - #{city} - #{Time.now.to_f - t.to_f}" if SHOW_PROVIDERS_TIME_INFO

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
