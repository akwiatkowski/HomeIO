#!/usr/bin/ruby1.9.1
#encoding: utf-8

require 'logger'
require 'singleton'
require './lib/utils/constants.rb'

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
def log_error( klass, exception )
  l = AdvLog.instance.logger( klass )
  l.error( exception.inspect )
  l.error( exception.backtrace )
end