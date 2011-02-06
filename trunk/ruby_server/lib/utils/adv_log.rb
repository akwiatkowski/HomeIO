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
#    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

require 'logger'
require 'singleton'
require 'lib/utils/constants'

# Store loggers instances

class AdvLog
  include Singleton

  DEFAULT_KLASS = 'HomeIO'

  def initialize
    prepare_directories

    @logs = Hash.new
    start_logger( DEFAULT_KLASS )

  end

  # Return logger for specified class, or universal logger if class wasn't specified
  # Create logger if needed
  def logger( klass = nil )
    if klass.nil?
      klass_name = DEFAULT_KLASS
    else
      klass_name = class_name( klass )
    end

    start_logger( klass_name ) if @logs[ klass_name ].nil?
    return @logs[ klass_name ]
  end

  private

  # Create logger
  def start_logger( klass_name )
    @logs[ klass_name ] = Logger.new( File.join( Constants::LOGS_DIR, "#{klass_name}.log" ) )
  end

  # Convert class to string name
  def class_name( k )
    return k.to_s if k.class.to_s == "Class"
    return k.class.to_s
  end

  # Create directories for logs if needed
  def prepare_directories
    if not File.exists?( Constants::DATA_DIR )
      Dir.mkdir( Constants::DATA_DIR )
    end

    if not File.exists?( Constants::LOGS_DIR )
      Dir.mkdir( Constants::LOGS_DIR )
    end
  end

end

# Easy error logging
def log_error( klass, exception, additional_info = nil )
  l = AdvLog.instance.logger( klass )
  l.error( exception.inspect )
  l.error( exception.backtrace )
  l.error( additional_info ) unless additional_info.nil?
end

# Easy error showing
def show_error( exception )
  puts exception.inspect
  puts exception.backtrace
end

# Set logger for RobustThread
require 'rubygems'
require 'robustthread'
RobustThread.logger = AdvLog.instance.logger( RobustThread )
