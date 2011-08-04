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

require 'lib/overseer/classes/average_overseer'

# A little less simple class used to control system. Check one type of measurement and perform actions when average value
# drops below or exceeds condition value, and if proc object return true.
#
# Useful when action should be executed only if some conditions are met, ex. proper state in hardware.

class AverageProcOverseer < AverageOverseer

  # Check if this Overseer is valid and can be started
  def valid?
    # proc must be not empty
    if proc.nil?
      puts "#{VERBOSE_PREFIX}Proc can not be nil"
      return false
    end

    # proc must return valid
    unless proc_result == true or proc_result == false
      puts "#{VERBOSE_PREFIX}Proc do not return true/false"
      return false
    end

    super
  end

  # Proc object, execute action only if
  def proc
    @params[:proc]
  end

  def proc_result
    # TODO add logging
    begin
      return proc.call
    rescue
      return nil
    end
  end

  private

  # Check if conditions are met
  def check
    res = super

    # proc result
    pr = proc_result
    @stats[:proc_result] = pr

    # proc call result must return true if 
    if res == true and pr == true
      puts "#{VERBOSE_PREFIX}#{self.class} standard and proc conditions MET (proc result #{pr})" if VERBOSE
      return true
    else
      puts "#{VERBOSE_PREFIX}#{self.class} conditions NOT met (proc result #{pr})" if VERBOSE
      return false
    end

  end


end
