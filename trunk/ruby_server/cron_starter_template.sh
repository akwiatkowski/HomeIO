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

# If you have problem with cron and rvm use this file
# in...
# @reboot                 bash /opt/homeio.sh > /tmp/homeio_init.log



export SHELL=/bin/bash
# /etc/profile.d/rvm.sh
[[ -s "/usr/local/rvm/scripts/rvm" ]] && . "/usr/local/rvm/scripts/rvm" # Load RVM function
rvm --default use 1.8.7@homeio2
ruby -v

cd /opt/HomeIO/trunk/ruby_server
bash start.sh --io --nginx