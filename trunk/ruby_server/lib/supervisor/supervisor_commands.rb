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
#    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.


# I put here all supervisor commands here, there are in 1 place now, or at least
# should be

class SupervisorCommands
  # testo command
  TEST = :test

  # text command send from IM bot
  IM_COMMAND = :im_command

  # start weather fetch
  FETCH_WEATHER = :fetch_weather

  # start metar fetch
  FETCH_METAR = :fetch_metar

  # process metars for 1 city
  PROCESS_METAR_CITY = :process_metar_city
end
