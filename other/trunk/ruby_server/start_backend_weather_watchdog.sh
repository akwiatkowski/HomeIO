#!/bin/bash

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


# Start weather watchdog

echo "Starting weather watchdog - interval 14 400 seconds (4 hours)"
for (( c=1; c>=0; c++ ))
do
  sleep 14400
  echo "Starting weather watchdog - weather for $c time @ `date`..."
  ruby lib/backend_weather_watchdog.rb
done