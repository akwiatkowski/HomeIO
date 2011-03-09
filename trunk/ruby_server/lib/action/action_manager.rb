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

require 'singleton'
require 'lib/utils/config_loader'
require "lib/storage/storage_active_record"

class ActionManager
  include Singleton

  # Cities definition array
  attr_reader :action_array

  # Get cities list for fetching
  def initialize
    @config = ConfigLoader.instance.config(self.class.to_s)
  end

  # Create AR objects and ActionType instances
  def initialize_type
    @config[:array].each do |m_def|
      # initialize AR object
      mt = ActionType.find_or_create_by_type(m_def[:type])
      m_def[:action_type_id] = mt.id

      # initialize MeasurementType object
      #@types << MeasurementType.new(m_def)
    end
  end


end
