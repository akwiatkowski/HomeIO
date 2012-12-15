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

require "singleton"
require File.join Dir.pwd, "lib/utils/start_threaded"
require File.join Dir.pwd, 'lib/utils/adv_log'
require File.join Dir.pwd, "lib/communication/db/extractor_active_record"

# Run thread and refresh weather prediction near site.

class ExtractorWeatherThreadProxy
  include Singleton

  attr_reader :wind_prediction, :temperature_prediction

  def initialize
    @rt = StartThreaded.start_threaded(30.minutes, self) do
      AdvLog.instance.logger(self).debug("Calculating weather #{Time.now}")
      refresh
      AdvLog.instance.logger(self).debug("Calculating weather finished #{Time.now}")
    end
  end

  private

  # Refresh weather prediction
  def refresh
    @wind_prediction = City.adv_attr_avg( :wind, 1.day )
    AdvLog.instance.logger(self).debug("Wind: #{@wind_prediction}")
    @temperature_prediction = City.adv_attr_avg( :temperature, 1.day )
    AdvLog.instance.logger(self).debug("Temperature: #{@temperature_prediction}")

    puts "* Weather thread proxy - temperature #{@temperature_prediction} oC"
    puts "* Weather thread proxy - wind speed #{@wind_prediction} m/s"

  end

end