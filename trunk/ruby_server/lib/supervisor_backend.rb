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


require "lib/utils/start_threaded"
require "lib/metar_logger"
require "lib/weather_ripper"
require "lib/measurement_fetcher"
require "lib/communication/task_server/tcp_comm_task_server"
require "lib/communication/simple_http/simple_http"

# Backend supervisor

class SupervisorBackend
  def initialize
    @config = ConfigLoader.instance.config(self)

    # metar
    @rt_metar = StartThreaded.start_threaded(@config[:intervals][:MetarLogger], self) do
      sleep 2
      MetarLogger.instance.start
    end

    # weather
    @rt_weather = StartThreaded.start_threaded(@config[:intervals][:WeatherRipper], self) do
      sleep 3
      WeatherRipper.instance.start
    end

    # 'hello' sample thread
    @rt_hello = StartThreaded.start_threaded(300, self) do
      puts "...alive #{Time.now}"
    end

    # updates city flags
    @rt_cities_flag_update = StartThreaded.start_threaded(@config[:intervals][:update_logged_flag], self) do
      sleep 300
      update_logged_flag
    end

    # communication server
    @task_comm_server = TcpCommTaskServer.new
    @rt_task_comm_server = @task_comm_server.start

    # measurements
    @measurement_fetcher = MeasurementFetcher.instance

    # simple http server
    @rt_simple_http = StartThreaded.start_threaded(@config[:intervals][:simple_http], self) do
      sleep @config[:intervals][:simple_http]
      SimpleHttp.new
    end
  end

  private

  # Update flags used for not searching through entire table when city has no weather or metar data
  def update_logged_flag
    StorageActiveRecord.instance.update_logged_flag
  end

end

# how to use? that way
#a = SupervisorBackend.new