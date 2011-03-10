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

require "lib/storage/storage_active_record"
require 'lib/communication/io_comm/io_protocol'

# Action (type)

class Action

  def initialize(config_hash)
    @config = config_hash
    @execution_count = 0
  end

  # Array sent to uC
  def command_array
    @config[:command][:array]
  end

  def execute(user_id = nil)
    io_result = IoProtocol.instance.fetch(command_array, response_size)
    raw_array = IoProtocol.string_to_array(io_result)
    status = (response_size == raw_array)

    post_execute(status, user_id)

    return status
  end

  # Add event to base and other things which should be done after executing events
  def post_execute(status, user_id)
    ActionEvent.create!(
      {
        :time => Time.now,
        :action_type_id => @config[:action_type_id],
        :error_status => (not status),
        :user_id => user_id
      }
    )

    @execution_count += 1
  end

  # Number of bytes of uC response
  def response_size
    @config[:command][:response_correct].size
  end

  # Number of bytes of uC response
  def response_correct
    @config[:command][:response_correct]
  end

end