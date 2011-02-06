#!/usr/bin/ruby
#encoding: utf-8

# This file is part of HomeIO.
#
#    HomeIO is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    HomeIO is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with HomeIO.  If not, see <http://www.gnu.org/licenses/>.

require "lib/utils/start_threaded"
require "lib/metar_logger"
require "lib/weather_ripper"


class HomeIoBackend
  def initialize
    rt_metar   = StartThreaded.start_threaded(180, self) do
      sleep 10
      MetarLogger.instance.start
    end

    rt_weather = StartThreaded.start_threaded(120, self) do
      sleep 5
      WeatherRipper.instance.start
    end

    rt_hello   = StartThreaded.start_threaded(10, self) do
      puts "HELLO #{Time.now}"
    end
  end

end

a = HomeIoBackend.new