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

require 'rubygems'
require 'json'
require 'socket'

require "lib/communication/db/extractor_basic_object"
require "lib/measurements/measurement_fetcher"

class SimpleHttp

  def initialize
    @server = TCPServer.new('0.0.0.0', 8080)
    while (session = @server.accept)
      session.print "HTTP/1.1 200/OK\r\nContent-type:text/html\r\n\r\n"
      request = session.gets
      req_filtered = request.gsub(/GET\ \//, '').gsub(/\ HTTP.*/, '').gsub(/\n/, '')
      req_array = req_filtered.split('/')

      content = execute_request(req_array).to_json
      session.print content

      session.close
    end
  end

  private

  # TODO add new comments, document
  def execute_request(req_array)
    if req_array[0] == "meas"
      return MeasurementFetcher.instance.get_last_hash
    end

    if req_array[0] == "metar"
      return ExtractorBasicObject.instance.get_last_metar(req_array[1])
    end

    return { :error => "No command" }
  end

end
