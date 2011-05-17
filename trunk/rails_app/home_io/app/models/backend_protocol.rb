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

# Initializers for backend communication with special TCP server.

class BackendProtocol < TcpCommProtocol

  # Get current measurements (Array of Hashes)
  def self._meas
    self.send_to_backend(:meas)
  end

  # Get current measurements (MeasArchives)
  def self.meas
    a = self._meas

    meas_archives = Array.new
    a.each do |m|
      ma = MeasArchive.new
      ma.time_from = m[:time]
      ma.time_to = m[:time]
      ma.raw = m[:raw]
      ma.value = m[:value]
      ma.meas_type = MeasType.find_by_name( m[:name] )
      ma.readonly!

      meas_archives << ma
    end

    meas_archives
  end

  # Send command (with params) to backend and return response
  def self.send_to_backend(command, params = nil)
    comm = TcpTask.factory(
      {
        :command => command,
        :params => params,
        :now => true
      }
    )
    res = TcpCommProtocol.send_to_server(comm, BACKEND_PROTOCOL_PORT, "localhost")

    return res.response
  end

end