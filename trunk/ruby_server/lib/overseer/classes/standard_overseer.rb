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

require 'lib/communication/db/extractor_active_record'
require 'lib/measurements/measurement_fetcher'
require 'lib/action/action_manager'
require 'lib/utils/start_threaded'

# Simple class used to control system. Check one type of measurement and perform actions when value drops below or
# exceeds sat value

class StandardOverseer

  def initialize
    @extractor = ExtractorActiveRecord.instance
    @measurement_fetcher = MeasurementFetcher.instance
    @measurement_array = @measurement_fetcher.meas_array
    @action_manager = ActionManager.instance

    # TODO create migration for overseers, list of overseers and parameters (like hash) for them
  end

  # Start
  def start
    @rt = StartThreaded.start_threaded(@config[:intervals][:MetarLogger], self) do
      sleep 2
      MetarLogger.instance.start
    end
  end

  def stop

  end

  private

  # Method
  def loop_method

  end

  def check

  end

  def execute_action

  end



end