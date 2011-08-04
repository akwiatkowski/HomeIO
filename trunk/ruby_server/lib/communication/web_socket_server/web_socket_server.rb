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

require 'singleton'
require 'rubygems'
require 'em-websocket'
require 'json'

require 'lib/communication/task_server/workers/home_io_standard_worker'
require 'lib/utils/adv_log'

# Simple web socket server for measurements and events. Under development.

class WebSocketServer
  include Singleton

  def initialize
    @worker = HomeIoStandardWorker.instance

    begin
      start
    rescue => e
      AdvLog.instance.logger(self).error("#{self.class.to_s} crashed")
      AdvLog.instance.logger(self).error(e.inspect)
    end

  end

  private

  def start
    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8082) do |ws|
      ws.onopen {
        # send initial message
        ws.send(on_init.to_json)
      }

      ws.onclose { { :closed => true } }
      ws.onmessage { |msg|
        puts "Recieved message: #{msg.inspect}"

        response = on_message(JSON.parse(msg))
        puts "RESPONSE"
        puts response.to_json
        ws.send(response.to_json)
      }
    end
  end

  # Initial message
  def on_init
    return { :test => 'ok' }
  end

  def on_message(msg)
    tcp_task = TcpTask.factory(msg)
    return @worker.process(tcp_task)
  end

end
