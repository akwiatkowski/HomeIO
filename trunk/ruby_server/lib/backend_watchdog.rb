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

require 'lib/communication/tcp/tcp_comm_protocol'
require 'lib/communication/task_server/tcp_task'
require 'lib/utils/config_loader'
require 'lib/storage/storage_active_record'
require 'lib/storage/active_record/backend_models/weather_archive'
require 'lib/storage/active_record/backend_models/weather_metar_archive'

# Run this file in cron to check if servers are running ok.
# They tend to freeze every week, I know this issue but it is hard to analyze
# what is wrong.

dir_path = "data/pid/"

class BackendWatchdog

  # restart control backend if earliest measurement is more than ... ago
  MEASUREMENTS_TIMEOUT = 15*60
  # restart weather backend if weathers are ... ago
  WEATHER_TIMEOUT = 12*3600
  METAR_TIMEOUT = 2*3600

  # show some info
  VERBOSE = true

  # right to kill
  ARMED = true

  def initialize
    @tcp_config = ConfigLoader.instance.config('TcpCommTaskServer')
    @tcp_port = @tcp_config[:port]

    @storage_ar = StorageActiveRecord.instance
  end

  def get_pids
    a = Array.new

    d = Dir.glob("#{dir_path}*.pid").each do |file_name|
      pid_file = File.new(file_name, "r")
      pid = pid_file.readline
      pid_file.close

      a << {
        :file => file_name,
        :pid => pid
      }
    end

    return pid
  end

  # Check if latest WeatherArchive was updated later than 12 hours ago
  # and latest WeatherMetarArchive was updated later than 2 hours ago
  def check_weather_backend
    # fetch last 20 WeatherArchive and WeatherMetarArchive sorting by id
    # and calculate minimum time

    a = WeatherArchive.order("id DESC").limit(20).all
    time = a.collect { |w| w.updated_at }.min
    time_d = Time.now - time
    puts "Weather interval = #{time_d}" if VERBOSE

    if time_d > WEATHER_TIMEOUT
      puts "Weather backend timeout"
      return true
    end

    a = WeatherMetarArchive.order("id DESC").limit(20).all
    time = a.collect { |w| w.updated_at }.min
    time_d = Time.now - time
    puts "Weather (metar) interval = #{time_d}" if VERBOSE

    if time_d > WEATHER_TIMEOUT
      puts "Weather backend timeout"
      return true
    end

    return false
  end

  # Tries to get current measurements via TCP, check if all of them are at least
  # later than 15 minutes ago
  #
  # Warning: time sync issue on virtual machines
  def check_control_backend
    comm = TcpTask.factory(
      {
        :command => :meas,
        :params => nil,
        :now => true
      }
    )
    res = TcpCommProtocol.send_to_server(comm, @tcp_port, "localhost")

    measurements_times = res.response.collect { |m| m[:time_to] }
    time = measurements_times.min
    time_d = Time.now - time

    puts "Control measurements interval = #{time_d}" if VERBOSE

    if time_d > MEASUREMENTS_TIMEOUT
      puts "Control backend timeout"
      return true
    else
      return false
    end

  end

end

b = BackendWatchdog.new
#puts b.check_control_backend.inspect
puts b.check_weather_backend

