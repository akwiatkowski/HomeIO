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


# Start control backend watchdog

echo "Starting backend watchdog - interval 300 seconds"
for (( c=1; c>=0; c++ ))
do
  sleep 300
  echo "Starting backend watchdog - control for $c time @ `date`"
  ruby lib/backend_control_watchdog.rb
done