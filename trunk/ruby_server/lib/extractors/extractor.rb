require './lib/extractors/extractor_active_record.rb'

# General purpose extreactor

class Extractor < ExtractorActiveRecord



  # Not safe method for running custom methods
  # Should be someting case like
  def remote_command( command )
    return nil
    # it's safe now...

    puts command.inspect
    method = command[:method]
    args = command[:args]
    return nil if method.nil?

    begin
      return self.send(method, *args)
    rescue => e
      # error - nil, it is safest
      puts "ERROR"
      puts e.inspect
      puts e.backtrace
      
      return nil
    end
  end

end
