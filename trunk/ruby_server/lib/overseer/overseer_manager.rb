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
require 'lib/utils/core_classes'
require "lib/storage/storage_active_record"

require 'lib/overseer/classes/standard_overseer'
require 'lib/overseer/classes/average_overseer'
require 'lib/overseer/classes/average_proc_overseer'

require 'lib/overseer/classes/custom/wind_turbine_overseer'

# Manage overseers instances and threads

class OverseerManager
  include Singleton

  def initialize
    StorageActiveRecord.instance

    @config = ConfigLoader.instance.config(self.class.to_s)
    @overseers_array = Array.new

    # DEADLOCK WARNING. Do not create overseers in this method.
  end

  # Add overseer objects (not threads) for fetching information about current status
  # This method is run in overseer. Custom overseers can add many primitive overseers.
  def register_overseer(overseer)
    @overseers_array << overseer
  end

  # List of registered overseers
  def overseers
    @overseers_array.collect{|o| o.to_hash}
  end

  # Load all overseer configuration from DB and yaml. Match all "yaml" to DB, if not present create it.
  # When there is overseer in DB, but no in yaml, mark it as disabled (o.active = false)
  # After DB is synchronized
  def start_all

  end

  
  def stop_all
    
  end

  private

  # Create AR objects and Overseer instances
  def initialize_overseers
    # TODO not implemented
    return

    @config[:array].each do |m_def|
      # initialize AR object
      mt = ActionType.find_or_create_by_name(m_def[:name])
      m_def[:action_type_id] = mt.id

      # initialize Action object
      @action_array << Action.new(m_def)
    end
  end

end