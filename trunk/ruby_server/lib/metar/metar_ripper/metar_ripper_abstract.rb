#!/usr/bin/ruby
#encoding: utf-8

# HomeIO - home control system.
# Copyright (C) 2011 Aleksander Kwiatkowski
#
# This file is part of HomeIO.
#
# HomeIO is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# HomeIO is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with HomeIO.  If not, see <http://www.gnu.org/licenses/>.


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
