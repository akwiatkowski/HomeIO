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


# METAR archives

class WeatherMetarArchive < ActiveRecord::Base
  belongs_to :city

  validates_uniqueness_of :raw, :scope => :time_from
  validates_uniqueness_of :city_id, :scope => :time_from
  validates_presence_of :raw, :time_from, :city_id

  validates_length_of :raw, :maximum => 200

  default_scope :order => "time_from DESC"

  scope :city_id, lambda { |city_id| where({:city_id => city_id}) }

  # will paginate
  cattr_reader :per_page
  @@per_page = 20
end
