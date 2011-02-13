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

require "lib/communication/db/extractor_active_record"

# Wrap extractor to communicate only using basic object (Hashes, Arrays)
# So no AR objects will be send via sockets

class ExtractorBasicObject < ExtractorActiveRecord

  # Get all cities
  def get_cities
    cities = super
    attrs  = cities.collect { |c| {
        :name    => c.attributes["name"],
        :country => c.attributes["country"],
        :lat     => c.attributes["lat"],
        :lon     => c.attributes["lon"],
        :id      => c.attributes["id"],
    } }
    return attrs
  end

end