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


# Interface for objectw which could be stored

module StorageInterface
  # Convert to hash object prepared to store_to_buffer in DB
  def to_db_data
    raise "Not implemented"

    return {
          :data => {},
          :columns => [],
        }

    #    return {
    #      :data => {
    #        :time_created => Time.now,
    #        :time_from => @output[:time].to_i,
    #        :time_to => (@output[:time].to_i + 30*60), # TODO przenieść do stałych
    #        :temperature => @output[:temperature],
    #        :pressure => @output[:pressure],
    #        :wind_kmh => @output[:wind],
    #        :wind => @output[:wind].nil? ? nil : @output[:wind].to_f / 3.6,
    #        :snow_metar => @snow_metar,
    #        :rain_metar => @rain_metar,
    #        :provider => 'METAR',
    #        :raw => @metar_string,
    #        :city_id => @city_id,
    #        :city => @city,
    #        :city_hash => @city_hash
    #      },
    #      :columns => [
    #        :time_created, :time_from, :time_to, :temperature, :pressure, :wind,
    #        :snow, :rain, :city_id, :raw
    #      ]
    #    }
  end
end
