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

require File.join Dir.pwd, 'lib/utils/adv_log'
require File.join Dir.pwd, 'lib/utils/config_loader'

# Run this file in cron to check if servers are running ok.
# They tend to freeze every week, I know this issue but it is hard to analyze
# what is wrong.


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

  # where are pid files
  DIR_PATH = "data/pid/"

  def initialize
    @logger = AdvLog.instance.logger(self)
  end

  # Flags for using only one type
  def can_check_weather!
    @can_check_weather = true
  end

  def can_check_weather?
    @can_check_weather == true
  end

  def can_check_meas!
    @can_check_meas = true
  end

  def can_check_meas?
    @can_check_meas == true
  end

  # DB initialization for weather checking
  def init_for_weather_check
    return if not @storage_ar.nil?

    # separating measurements from weather
    require File.join Dir.pwd, 'lib/storage/storage_active_record'
    require File.join Dir.pwd, 'lib/storage/active_record/backend_models/weather_archive'
    require File.join Dir.pwd, 'lib/storage/active_record/backend_models/weather_metar_archive'

    @storage_ar = StorageActiveRecord.instance
    @storage_ar
  end

  # TCP client initialization for weather checking
  def init_for_meas_check
    return @tcp_port if not @tcp_port.nil?

    # separating measurements from weather
    require File.join Dir.pwd, 'lib/communication/tcp/tcp_comm_protocol'
    require File.join Dir.pwd, 'lib/communication/task_server/tcp_task'

    @tcp_config = ConfigLoader.instance.config('TcpCommTaskServer')
    @tcp_port = @tcp_config[:port]
  end

  def scan_pids
    pids = get_pids

    pids.each do |p|
      if p[:file] =~ /control/ and can_check_meas?
        init_for_meas_check

        txt = "Checking control"
        puts txt
        @logger.debug(txt)

        kill_pid(p) if check_control_backend
      end

      if p[:file] =~ /weather/ and can_check_weather?
        init_for_weather_check

        txt = "Checking weather"
        puts txt
        @logger.debug(txt)

        kill_pid(p) if check_weather_backend
      end

    end
  end

  def get_pids
    a = Array.new

    d = Dir.glob("#{DIR_PATH}*.pid").each do |file_name|
      pid_file = File.new(file_name, "r")
      pid = pid_file.readline
      pid_file.close

      a << {
        :file => file_name,
        :pid => pid
      }
    end

    return a
  end

  def kill_pid(p)
    # safe mode
    return unless ARMED

    pid = p[:pid]
    file_name = p[:file]

    txt = "Killing #{file_name} - PID  #{pid}"
    puts txt
    @logger.warn(txt)

    `kill -9 #{pid}`
    `rm #{file_name}`
  end

  # Check if latest WeatherArchive was updated later than 12 hours ago
  # and latest WeatherMetarArchive was updated later than 2 hours ago
  def check_weather_backend
    # fetch last 20 WeatherArchive and WeatherMetarArchive sorting by id
    # and calculate minimum time

    a = WeatherArchive.order("id DESC").limit(20).all
    time = a.collect { |w| w.updated_at }.min
    time_d = Time.now - time
    txt = "Weather interval = #{time_d} (#{(time_d / 60).to_i} min, #{(time_d / 3600).to_i} h, threshold #{WEATHER_TIMEOUT})"
    puts txt if VERBOSE
    @logger.debug(txt)

    if time_d > WEATHER_TIMEOUT
      txt = "Weather backend timeout"
      puts txt
      @logger.warn(txt)

      return true
    end

    a = WeatherMetarArchive.order("id DESC").limit(20).all
    time = a.collect { |w| w.updated_at }.min
    time_d = Time.now - time
    txt = "Weather (metar) interval = #{time_d} (#{(time_d / 60).to_i} min, #{(time_d / 3600).to_i} h, threshold #{MEASUREMENTS_TIMEOUT})"
    puts txt if VERBOSE
    @logger.debug(txt)

    if time_d > WEATHER_TIMEOUT
      txt = "Weather backend timeout"
      puts txt
      @logger.warn(txt)

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

    txt = "Control measurements interval = #{time_d} (#{(time_d / 60).to_i} min, #{(time_d / 3600).to_i} h, threshold #{MEASUREMENTS_TIMEOUT})"
    puts txt if VERBOSE
    @logger.debug(txt)


    if time_d > MEASUREMENTS_TIMEOUT
      txt = "Control backend timeout"
      puts txt if VERBOSE
      @logger.warn(txt)

      return true
    else
      return false
    end

  end

end
