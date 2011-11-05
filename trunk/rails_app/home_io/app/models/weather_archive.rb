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


# Weather archives, non-metar

class WeatherArchive < ActiveRecord::Base
  belongs_to :city
  belongs_to :weather_provider

  validates_uniqueness_of :time_from, :scope => [:weather_provider_id, :city_id, :time_to]
  validates_presence_of :time_from, :time_to, :city_id, :weather_provider_id

  # will paginate
  cattr_reader :per_page
  @@per_page = 20

  default_scope :order => "time_from DESC"

  scope :city_id, lambda { |city_id| where({:city_id => city_id}) }

  # This was stored based by future prediction
  def predicted?
    if self.updated_at >= self.time_from
      return false
    else
      return true
    end
  end

end
