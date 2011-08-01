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
require "lib/metar/metar_logger"
require "lib/weather_ripper/weather_ripper"

# Run this file if you wish to start fetching weather data. They are only used when stored in DB.

puts "Backend - Weather"

@config = ConfigLoader.instance.config('SupervisorBackend')

# metar
@rt_metar = StartThreaded.start_threaded(@config[:intervals][:MetarLogger], self) do
  puts "Backend thread - METAR"
  sleep @config[:sleeps][:MetarLogger]
  MetarLogger.instance.start
end

# weather
@rt_weather = StartThreaded.start_threaded(@config[:intervals][:WeatherRipper], self) do
  puts "Backend thread - Weather"
  sleep @config[:sleeps][:MetarLogger]
  WeatherRipper.instance.start
end

# updates city flags, db fetching optim.
@rt_cities_flag_update = StartThreaded.start_threaded(@config[:intervals][:update_logged_flag], self) do
  puts "Backend thread - flag updater"
  sleep @config[:sleeps][:MetarLogger]
  StorageActiveRecord.instance.update_logged_flag
end
