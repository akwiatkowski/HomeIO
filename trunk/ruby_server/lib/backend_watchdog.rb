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

# Run this file in cron to check if servers are running ok.
# They tend to freeze every week, I know this issue but it is hard to analyze
# what is wrong.

dir_path = "data/pid/"

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
# and latest WeatherMetarArchive was updated later than 3 hours ago
def check_weather_backend

end

# Tries to get current measurements via TCP, check if all of them are at least
# later than 15 minutes ago
#
# Warning: time sync issue on virtual machines
def check_control_backend
  
end

