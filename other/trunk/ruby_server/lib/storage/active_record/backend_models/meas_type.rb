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

# some issues with HABTM

#require File.join Dir.pwd, 'lib/storage/active_record/rails_models/meas_type'

#class MeasType
#end

class MeasType < ActiveRecord::Base
  has_many :meas_archives

  validates_presence_of :name
  validates_uniqueness_of :name

  set_inheritance_column :sti_type

  # Use I18n
  def name_human
    self.name.humanize
  end

end

