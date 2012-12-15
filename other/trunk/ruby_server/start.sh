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


# Usage:
# --init - perform RVM initialization
# --io - start IoServer (bash start_ioserver.sh)
# --noweather - do not start weather backend
# --nocontrol - do not start control backend
# --nginx - start or restart nginx





# all capabilities, create and detach, more optimum output
# start screen
screen -admS homeio top



# start ioserver when "--io" argument was added
for var in "$@"
do
    # echo "$var"
    if [ $var == "--io" ]
    then
        echo "Start IO"
        screen -rm homeio -X screen bash start_ioserver.sh
    fi
done



# add weather backend
NO_WEATHER="0"
for var in "$@"
do
    # echo "$var"
    if [ $var == "--noweather" ]
    then
        NO_WEATHER="1"
    fi
done

if [ $NO_WEATHER == "1" ]
then
  echo "No weather backend"
else
  screen -rm homeio -X screen bash start_backend_weather.sh
  screen -rm homeio -X screen bash start_backend_weather_watchdog.sh
fi



# add control backend
NO_CONTROL="0"
for var in "$@"
do
    # echo "$var"
    if [ $var == "--nocontrol" ]
    then
        NO_CONTROL="1"
    fi
done

if [ $NO_CONTROL == "1" ]
then
  echo "No control backend"
else
  screen -rm homeio -X screen bash start_backend_control.sh
  screen -rm homeio -X screen bash start_backend_control_watchdog.sh
fi



# re/start nginx when "--nginx" argument was added
for var in "$@"
do
    # echo "$var"
    if [ $var == "--nginx" ]
    then
        echo "Re/start nginx"
        screen -rm homeio -X screen bash start_nginx.sh
    fi
done



