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


# Wrapper for periodically started tasks

require 'rubygems'
require 'robustthread'
require 'lib/utils/adv_log'
require 'lib/utils/dev_info'

class StartThreaded

  # Wrap code block to be started in loop with begin-rescue-end. There is 1 second sleep every finished task.
  #
  # :call-seq:
  #   StartThreaded.start_threaded( Numeric interval, parent instance) {code block} => RobustThread handle
  def self.start_threaded(interval, parent, &block)
    self.start_threaded_precised(interval, 1.0, parent, &block)
  end

  # Wrap code block to be started in loop with begin-rescue-end.
  #
  # :call-seq:
  #   StartThreaded.start_threaded( Numeric interval, Numeric sleep after execution, parent instance) {code block} => RobustThread handle
  def self.start_threaded_precised(interval, sleep_time, parent, &block)

    # create new thread
    label = AdvLog.instance.class_name(parent)
    rt = RobustThread.new(:label => label, :args => [interval, parent, sleep_time, block]) do |t_interval, t_parent, t_sleep_time, t_block|

      # loop in thread
      time_ok = nil
      loop do
        begin
          # is it time to execute?
          # if never executed or interval has passed
          if time_ok.nil? or (Time.now - time_ok) > t_interval
            # used later fo interval checking
            time_started = Time.now

            # execute
            # in case of exception it will be started again
            t_block.call

            # when execution is done without errors set this variable
            # when Time.now - time_ok > t_interval execute another time
            time_ok = time_started
          else
            # do nothing
          end

          # wait a little
          sleep(t_sleep_time)

        rescue => e
          # something went wrong - show and log error as parent
          log_error(t_parent, e)
          show_error(e)
        end
      end

    end

    return rt
  end

  # Kill all threads, all but main
  def self.kill_all_sub_threads
    Thread.list.each do |t|
      t.kill unless t == Thread.main
    end
  end

end