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
#    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

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
screen -rm homeio -X screen bash start_backend_weather.sh

# add control backend
screen -rm homeio -X screen bash start_backend_control.sh

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



