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


# store PID
require 'lib/utils/pid'

require "lib/utils/start_threaded"
require "lib/measurements/measurement_fetcher"
require "lib/communication/task_server/tcp_comm_task_server"
require "lib/communication/simple_http/simple_http"
require 'lib/communication/web_socket_server/web_socket_server'

# Run this file if you wish to start control system (measure and control), and start communication servers.

puts "Backend - Control"

@config = ConfigLoader.instance.config('SupervisorBackend')

# measurements fetching
@measurement_fetcher = MeasurementFetcher.instance

# overseer manager
@overseer_manager = OverseerManager.instance
@overseer_manager.start_all

# communication server
@task_comm_server = TcpCommTaskServer.new
@rt_task_comm_server = @task_comm_server.start


# simple http server
@rt_simple_http = StartThreaded.start_threaded(@config[:intervals][:simple_http], self) do
  sleep @config[:sleeps][:simple_http]
  SimpleHttp.new
end

# web socket server
# unstable
#@rt_websocket = StartThreaded.start_threaded(@config[:intervals][:simple_http], self) do
#  sleep @config[:sleeps][:simple_http]
#  WebSocketServer.instance
#end

puts "Backend control, init finished"