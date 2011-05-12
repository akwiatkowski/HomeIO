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

require 'lib/utils/config_loader'
require "lib/communication/db/extractor_basic_object"
require "lib/measurements/measurement_fetcher"

class SimpleHttp

  ERROR_NO_COMMAND = 1
  ERROR_EXEC_ERROR = 2

  def initialize
    @config = ConfigLoader.instance.config(self)

    @server = TCPServer.new('0.0.0.0', 8080)
    while (session = @server.accept)
      session.print "HTTP/1.1 200/OK\r\nContent-type:application/json\r\n\r\n"
      request = session.gets
      req_filtered = request.gsub(/GET\ \//, '').gsub(/\ HTTP.*/, '').gsub(/\n/, '')
      req_array = req_filtered.split('/')

      begin
        content = execute_request(req_array).to_json
      rescue
        content = { :error => "Execution error", :error_code => ERROR_EXEC_ERROR }
      end
      session.print content

      session.close
    end
  end

  private

  # TODO add new comments, document
  def execute_request(req_array)
    # summary of all measurements
    if req_array[0] == "meas"
      return MeasurementFetcher.instance.get_last_hash
    end

    # detail of measurement
    if req_array[0] == "meas_type"
      return MeasurementFetcher.instance.get_meas_type_by_name(req_array[1]).to_hash_detailed
    end

    # cache of measurement
    if req_array[0] == "meas_cache"
      return MeasurementFetcher.instance.get_meas_type_by_name(req_array[1]).cache
    end

    if req_array[0] == "metar"
      return ExtractorBasicObject.instance.get_last_metar(req_array[1])
    end

    return { :error => "No command", :error_code => ERROR_NO_COMMAND }
  end

end
