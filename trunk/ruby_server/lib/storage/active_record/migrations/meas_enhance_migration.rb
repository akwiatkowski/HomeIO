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

class MeasEnhanceMigration < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base. transaction do
      add_column :meas_archives, :time_from_us, :float, :null => false, :default => 0.0
      add_column :meas_archives, :time_to_us, :float, :null => false, :default => 0.0
    end
  end

  def self.down
    remove_column :meas_archives, :time_from_us, :time_to_us
  end
end
