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
    # add to array
    @overseers_array << overseer

    # check and populate DB
    o = Overseer.find_by_name(overseer.name)
    if o.nil?
      # create Overseer with OverseerParameters
      Overseer.transaction do
        o = Overseer.create!(
          {
            :name => overseer.name,
            :klass => overseer.class.to_s,
            :active => overseer.active
          }
        )

        # add parameters
        p = overseer.params
        op = Array.new
        p.keys.each do |k|
          # fix for proc objects
          value = p[k]
          value = nil if value.kind_of? Proc

          op << OverseerParameter.new(
            {
              :key => k,
              :value => value
            }
          )
          o.overseer_parameters = op
          o.save!
        end

      end
    end

    # set overseer id used when executing actions
    # TODO try something else using models
    overseer.set_overseer_id(o)

  end

  # List of registered overseers
  def overseers
    @overseers_array.collect { |o| o.to_hash }
  end

  # Load all overseer configuration from DB and yaml. Match all "yaml" to DB, if not present create it.
  # When there is overseer in DB, but no in yaml, mark it as disabled (o.active = false)
  # After DB is synchronized
  def start_all
    start_primitive_overseers
    start_custom_overseers
  end


  def stop_all

  end

  private

  def start_primitive_overseers
    # TODO use factory class
  end

  def start_custom_overseers
    # no custom overseers configuration available
    return if @config[:custom].nil?

    # custom overseer for wind turbine
    if not @config[:custom][:wind_turbine].nil? and @config[:custom][:wind_turbine][:enabled] == true
      WindTurbineOverseer.new(@config[:custom][:wind_turbine][:params]).start
    end
  end

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