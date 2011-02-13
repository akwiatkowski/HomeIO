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

require 'logger'
require 'singleton'
require 'lib/utils/constants'

# Store loggers instances for every class which need logging

class AdvLog
  include Singleton

  # Default log name
  DEFAULT_KLASS = 'HomeIO'

  # Create directories and start default logger
  def initialize
    prepare_directories

    @logs = Hash.new
    start_logger(DEFAULT_KLASS)
  end

  # Return logger for specified class, or universal logger if class wasn't specified
  # Create logger if needed
  #
  # :call-seq:
  #   logger => default Logger
  #   logger( Class ) => Logger for class
  #   logger( class instance ) => Logger for class
  def logger(klass = nil)
    if klass.nil?
      klass_name = DEFAULT_KLASS
    else
      klass_name = class_name(klass)
    end

    start_logger(klass_name) if @logs[klass_name].nil?
    return @logs[klass_name]
  end

  # Convert class to string name
  #
  # :call-seq:
  #   class_name( object ) => String, class name
  #   class_name( Class ) => String, class.to_s
  def class_name(k)
    return k.to_s if k.class.to_s == "Class" or k.class.to_s == "String" 
    return k.class.to_s
  end


  private

  # Create logger for class
  #
  # :call-seq:
  #   start_logger( String ) => Logger
  def start_logger(klass_name)
    @logs[klass_name] = Logger.new(File.join(Constants::LOGS_DIR, "#{klass_name}.log"))
  end

  # Create directories for logs if needed
  def prepare_directories
    if not File.exists?(Constants::DATA_DIR)
      Dir.mkdir(Constants::DATA_DIR)
    end

    if not File.exists?(Constants::LOGS_DIR)
      Dir.mkdir(Constants::LOGS_DIR)
    end
  end

end

# Easy error logging
#
# :call-seq:
#   log_error( Class, Exception )
#   log_error( Class, Exception, String additional info )
#   log_error( String class name, Exception )
#   log_error( String class name, Exception, String additional info ) 
def log_error(klass, exception, additional_info = nil)
  l = AdvLog.instance.logger(klass)
  l.error(exception.inspect)
  l.error(exception.backtrace)
  l.error(additional_info) unless additional_info.nil?
end

# Easy error printing on screen
#
# :call-seq:
#   show_error( Exception )
def show_error(exception)
  puts exception.inspect
  puts exception.backtrace
end

# Set logger for RobustThread
require 'rubygems'
require 'robustthread'
RobustThread.logger = AdvLog.instance.logger
