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

require 'lib/overseer/classes/standard_overseer'
require 'lib/overseer/classes/average_overseer'
require 'lib/overseer/classes/average_proc_overseer'
require 'lib/measurements/measurement_fetcher'

# Custom wind turbine overseer. Written for easter deploy.

class WindTurbineOverseer

  INTERVAL = 10

  # SUB_OVERSEERS_CLASS = AverageOverseer # working, without proc
  SUB_OVERSEERS_CLASS = AverageProcOverseer

  def initialize
    @inv_a_on_overseer = SUB_OVERSEERS_CLASS.new(
      {
        :measurement_name => "batt_u", #- type of measurement which is checked
        :greater => true, #true/false, true - check if value is greater
        :threshold_value => 38.0, #- value which is compared to
        :action_name => "output_2_on", #- action type to execute if check is true
        :average_count => 20,
        :interval => INTERVAL,
        :re_execute => false,
        :proc => Proc.new { not first_inverter_on? }
      }
    )

    @inv_a_off_overseer = SUB_OVERSEERS_CLASS.new(
      {
        :measurement_name => "batt_u", #- type of measurement which is checked
        :greater => false, #true/false, true - check if value is greater
        :threshold_value => 34.0, #- value which is compared to
        :action_name => "output_2_off", #- action type to execute if check is true
        :average_count => 20,
        :interval => INTERVAL,
        :re_execute => false,
        :proc => Proc.new { first_inverter_on? }
      }
    )

    @inv_b_on_overseer = SUB_OVERSEERS_CLASS.new(
      {
        :measurement_name => "batt_u", #- type of measurement which is checked
        :greater => true, #true/false, true - check if value is greater
        :threshold_value => 40.0, #- value which is compared to
        :action_name => "output_3_on", #- action type to execute if check is true
        :average_count => 40,
        :interval => INTERVAL,
        :re_execute => false,
        :proc => Proc.new { not second_inverter_on? }

      }
    )

    @inv_b_off_overseer = SUB_OVERSEERS_CLASS.new(
      {
        :measurement_name => "batt_u", #- type of measurement which is checked
        :greater => false, #true/false, true - check if value is greater
        :threshold_value => 36.0, #- value which is compared to
        :action_name => "output_3_off", #- action type to execute if check is true
        :average_count => 30,
        :interval => INTERVAL,
        :re_execute => false,
        :proc => Proc.new { second_inverter_on? }
      }
    )
  end

  def start
    @inv_a_on_overseer.start
    @inv_a_off_overseer.start
    @inv_b_on_overseer.start
    @inv_b_off_overseer.start
  end

  def first_inverter_on?
    begin
      (MeasurementFetcher.instance.get_value_by_name("outputs").to_i & 2) > 0
    rescue
      puts "First inverter status can not be read"
      false
    end
  end

  def second_inverter_on?
    begin
      (MeasurementFetcher.instance.get_value_by_name("outputs").to_i & 4) > 0
    rescue
      puts "Second inverter status can not be read"
      false
    end
  end


end