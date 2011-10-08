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


# Measurement types

class MeasType < ActiveRecord::Base
  belongs_to :meas_type_group
  has_many :meas_archives

  validates_presence_of :name
  validates_uniqueness_of :name

  # will paginate
  cattr_reader :per_page
  @@per_page = 20

  set_inheritance_column :sti_type

  # recent measurements
  # not working, maybe later rewrite
  #scope :recent_measurements, lambda { |meas_type_id| where('id = ?', meas_type_id).meas_archives.recent }
  
  # Use I18n
  def name_human
    self.name.humanize
  end

end
