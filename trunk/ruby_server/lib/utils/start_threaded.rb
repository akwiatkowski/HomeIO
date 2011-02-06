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
#    along with HomeIO.  If not, see <http://www.gnu.org/licenses/>.


# Wrapper for periodically started tasks

require 'rubygems'
require 'robustthread'
require 'lib/utils/adv_log'
require 'lib/utils/dev_info'

class StartThreaded

  # Wrap code block to be started in loop with begin-rescue-end
  #
  # :call-seq:
  #   StartThreaded.start_threaded( Numeric interval, parent instance) {code block}
  def self.start_threaded(interval, parent, &block)

    # create new thread
    label = AdvLog.instance.class_name(parent)
    RobustThread.new(:label => label, :args => [interval, parent, block]) do |t_interval, t_parent, t_block|

      # loop in thread
      loop do
        begin
          # is it time to execute?
          # if never executed or interval has passed
          if not defined? time_ok or (Time.now - time_ok) > t_interval
            # used later fo interval checking
            time_started = Time.now

            # execute
            # in case of exception it will be started again 
            t_block.call

            # when execution is done without errors set this variable
            # when Time.now - time_ok > t_interval execute another time
            time_ok = Time.now
          else
            # do nothing
          end

          # wait a little
          sleep(1)

        rescue => e
          # something went wrong - show and log error as parrent
          log_error(parent, e)
          show_error(e)
        end
      end

    end

  end

end