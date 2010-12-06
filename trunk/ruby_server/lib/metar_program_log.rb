require 'logger'
require 'singleton'

# Store loggers classes

class MetarProgramLog
  include Singleton

  DEFAULT_KLASS = 'HomeIO'

  def initialize
    @logs = Hash.new
    start_logger( DEFAULT_KLASS )
  end

  # Return logger for specified class, or universal logger
  # Create if needed
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

  def start_logger( klass_name )
    @logs[ klass_name ] = Logger.new( File.join( MetarTools::LOGS_DIR, "#{klass_name}.log" ) )
  end

  def class_name( k )
    return k.class.to_s
  end

end

# Easy error logging
def log_error( klass, exception )
  l = MetarProgramLog.instance.logger( klass )
  l.error( exception.inspect )
  l.error( exception.backtrace )
end