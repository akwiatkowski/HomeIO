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


# Simple task used for communication with TcpTaskSupervisor

class TcpTask
  # When task was created, Time
  attr_reader :time_new

  # When task was started, Time or nil
  attr_reader :time_started

  # When task was finished, Time or nil
  attr_reader :time_finished

  # When task response was sent, Time or nil
  attr_reader :time_sent

  # When task can't be processed @error is true
  attr_reader :error

  # Command sent to server
  attr_accessor :command

  # Additional parameters
  attr_accessor :params

  # Result from server
  attr_accessor :response

  # Result from server
  attr_accessor :now

  # Time of processing command
  attr_reader :process_time

  # Status
  attr_reader :status

  DONE = :done
  NEW = :new
  SENT = :sent
  IN_PROCESS = :in_process

  # Used for waiting loop
  def fetch_is_ready?
    if self.status == DONE
      return true
    end
    return false
  end

  # Id used for fetching response later
  attr_reader :result_fetch_id

  # Reason for error
  attr_reader :reason

  # Additional parameter for error
  attr_reader :error_params


  # Create new task
  #
  # :call-seq:
  #   TcpTask.new({:command => Symbol, :now => Boolean, :priority => Integer}
  def initialize(h = {})
    # main command
    @command = h[:command]
    @params = h[:params]

    # default tasks are processed inside queue
    @now = false
    @now = h[:now] if true == h[:now]

    @status = NEW
    @status = h[:status] unless h[:status].nil?

    @priority = 0
    @priority = h[:priority].to_i unless h[:priority].nil?

    @error = false
    @time_new = Time.now
  end

  # Create new TcpTask from hash or return TcpTask object
  def self.factory(obj)
    if obj.kind_of?(TcpTask)
      return obj
    end

    if obj.kind_of?(Hash)
      return TcpTask.new(obj)
    end

    return nil
  end

  # Is new?, not done yet
  def is_new?
    return true if self.status == NEW
    return false
  end

  # Is ready?
  def is_ready?
    return true if self.status == DONE
    return false
  end

  # Was sent?
  def is_sent?
    return true if self.status == SENT
    return false
  end

  # Is processed right now?
  def is_in_process?
    return true if self.status == IN_PROCESS
    return false
  end

  # Was task finished - ready to fetch?
  def finished?
    return true if is_ready? or is_sent?
    return false
  end

  # Set task is processing right now
  def set_in_process!
    @status = IN_PROCESS
    @time_started = Time.now
  end

  def set_done!
    @status = DONE
    @time_finished = Time.now

    if not @time_finished.nil? and not @time_started.nil?
      @process_time = @time_finished.to_f - @time_started.to_f
    else
      @process_time = nil
    end
  end

  # Set task result was sent
  def set_sent!
    @status = SENT
    @time_sent = Time.now

    if @time_finished.nil?
      @time_finished = Time.now
      @process_time = nil
    end
  end

  # Task can not be processed
  def set_error!(reason = :unknown, error_params = nil)
    set_done!
    @error = true
    @error_reason = reason
    @error_params = error_params
  end

  # Is command with Proc
  def type_proc?
    self.command.kind_of?(Proc)
  end

  # Is command normal, not Proc
  def type_normal?
    self.command.kind_of?(Symbol) or self.command.kind_of?(Hash)
  end

  # Run Proc command
  def run_proc(klass_instance)
    return nil if false == self.type_proc?

    begin
      self.response = command.call(klass_instance)
    rescue => e
      self.response = nil
      set_error!(:proc_failed, e.inspect)

      puts e.inspect
      puts e.backtrace
      log_error(self, e, "task.inspect #{self.inspect}")
    end
  end

  # Very hurry task, is processed outside queue
  def process_now?
    return @now
  end

  # Generate id for fetching it later
  def generate_fetch_id!
    @result_fetch_id = self.object_id
  end

  # Set response that task was added to queue
  def set_response_added!
    @response = :added
  end


end
