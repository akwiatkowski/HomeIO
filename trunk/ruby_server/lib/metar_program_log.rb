require 'logger'

# Log działania samego programu

class MetarProgramLog
  def self.start_logger
    @@_logger = Logger.new( File.join( MetarTools::DATA_DIR, "server.log" ) )
  end

  def self.log
    if not defined? @@_logger
      MetarProgramLog.start_logger
    end
    return @@_logger
  end
end
