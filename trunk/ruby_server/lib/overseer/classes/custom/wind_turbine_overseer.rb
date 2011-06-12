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
require 'lib/communication/db/extractor_weather_thread_proxy'

# Custom wind turbine overseer. Written for easter deploy.

class WindTurbineOverseer

  INTERVAL = 10

  SUB_OVERSEERS_CLASS = AverageProcOverseer

  def initialize(params)
    @params = params

    # settable parameters
    measurement_name = @params[:battery_voltage_measurement_name]
    wrong_params if measurement_name.nil?

    interval = @params[:interval]
    interval = INTERVAL if interval.nil?

    inv_a_count_to_average = @params[:inv_a_count_to_average]
    wrong_params if inv_a_count_to_average.nil?

    inv_b_count_to_average = @params[:inv_b_count_to_average]
    wrong_params if inv_b_count_to_average.nil?

    threshold_inv_a_on = @params[:threshold_inv_a_on]
    threshold_inv_a_off = @params[:threshold_inv_a_off]
    threshold_inv_b_on = @params[:threshold_inv_b_on]
    threshold_inv_b_off = @params[:threshold_inv_b_off]


    @inv_a_on_overseer = SUB_OVERSEERS_CLASS.new(
      {
        :name => "inverter A on",
        :measurement_name => measurement_name, #- type of measurement which is checked
        :greater => true, #true/false, true - check if value is greater
        :threshold_value => threshold_inv_a_on, #- value which is compared to
        :action_name => "output_2_on", #- action type to execute if check is true
        :average_count => inv_a_count_to_average,
        :interval => interval,
        :re_execute => false,
        :proc => Proc.new { not first_inverter_on? },
        :threshold_proc => Proc.new { self.batteries_weather_offset }
      }
    )

    @inv_a_off_overseer = SUB_OVERSEERS_CLASS.new(
      {
        :name => "inverter A off",
        :measurement_name => measurement_name, #- type of measurement which is checked
        :greater => false, #true/false, true - check if value is greater
        :threshold_value => threshold_inv_a_off, #- value which is compared to
        :action_name => "output_2_off", #- action type to execute if check is true
        :average_count => inv_a_count_to_average,
        :interval => interval,
        :re_execute => false,
        :proc => Proc.new { first_inverter_on? },
        :threshold_proc => Proc.new { self.batteries_weather_offset }
      }
    )

    @inv_b_on_overseer = SUB_OVERSEERS_CLASS.new(
      {
        :name => "inverter B on",
        :measurement_name => measurement_name, #- type of measurement which is checked
        :greater => true, #true/false, true - check if value is greater
        :threshold_value => threshold_inv_b_on, #- value which is compared to
        :action_name => "output_3_on", #- action type to execute if check is true
        :average_count => inv_b_count_to_average,
        :interval => interval,
        :re_execute => false,
        :proc => Proc.new { not second_inverter_on? },
        :threshold_proc => Proc.new { self.batteries_weather_offset }
      }
    )

    @inv_b_off_overseer = SUB_OVERSEERS_CLASS.new(
      {
        :name => "inverter B off",
        :measurement_name => measurement_name, #- type of measurement which is checked
        :greater => false, #true/false, true - check if value is greater
        :threshold_value => threshold_inv_b_off, #- value which is compared to
        :action_name => "output_3_off", #- action type to execute if check is true
        :average_count => inv_b_count_to_average,
        :interval => interval,
        :re_execute => false,
        :proc => Proc.new { second_inverter_on? },
        :threshold_proc => Proc.new { self.batteries_weather_offset }
      }
    )
  end

  def wrong_params
    puts @params.inspect
    raise 'Not enough parameters'
  end

  def start
    @inv_a_on_overseer.start
    @inv_a_off_overseer.start
    @inv_b_on_overseer.start
    @inv_b_off_overseer.start
  end

  # Batteries voltage offset using weather prediction
  def batteries_weather_offset
    wind_speed_prediction = ExtractorWeatherThreadProxy.instance.temperature_prediction

    # no weather prediction, no offset
    return 0.0 if wind_speed_prediction.nil?

    # 2.6V within delta 8m/s of wind speed
    offset = 1.2 - wind_speed_prediction * ( 2.6 / 8.0)
    offset = 1.5 if offset > 1.5 # safety, wind should be always > 0
    offset = -2.6 if offset < -2.6 # safety
    return offset
  end

  def first_inverter_on?
    begin
      outputs = MeasurementFetcher.instance.get_value_by_name("outputs").to_i
      check_outputs = (outputs & 2) > 0
      puts "First inverter outputs #{outputs}, check_outputs #{check_outputs}"
      return check_outputs
    rescue
      puts "First inverter status can not be read"
      false
    end
  end

  def second_inverter_on?
    begin
      outputs = MeasurementFetcher.instance.get_value_by_name("outputs").to_i
      check_outputs = (outputs & 4) > 0
      puts "Second inverter outputs #{outputs}, check_outputs #{check_outputs}"
      return check_outputs
    rescue
      puts "Second inverter status can not be read"
      false
    end
  end


end