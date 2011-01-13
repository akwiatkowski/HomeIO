require 'singleton'
require './lib/utils/core_classes.rb'
require './lib/metar/metar_code.rb'
require './lib/utils/dev_info.rb'
require './lib/weather_ripper/weather.rb'

# Basic raw weather (non-metar) storage in text files

class WeatherStorage
  include Singleton
  
  def store( obj )
    # Store only raw metars
    return nil unless obj.kind_of?( Weather )

    return store_weather( obj )
  end

  # Prepare main directories
  def init
    # not needed, delete?
    # prepare_main_directories
  end

  def deinit
    # wont be implemented!
  end

  def flush
  end

  # Raw storage - always enabled
  def config
    return {:enabled => true}
  end


  private

  # Store weather in files
  def store_weather( obj )
    # invalid metars won't be stored
    return :invalid unless obj.valid?

    prepare_directories( obj )
    return :was_logged unless not_logged?( obj )
    return :ok if append_weather( obj )
    return :failed
  end

  # Check if weather wasn't already logged
  def not_logged?( obj )
    fp = filepath( obj )
    text_line = obj.text_weather_store_string

    if File.exists?( fp )
      f = File.open( fp, "r" )
      f.each_line do |l|
        # check every line
        if not l.index( text_line ).nil?
          # checked for substring - positive, metar was logged
          f.close
          return false 
        end
      end
      f.close
    end
    
    # file doesn't exist so not logged
    return true
  end

  # Append metar at end of log
  def append_weather( obj )
    f = File.open( filepath( obj ), "a" )
    f.puts obj.text_weather_store_string + "\n"
    f.close

    puts "Stored: #{obj.short_info}"
    DevInfo.instance.inc( self.class.to_s, :weathers_logged )

    return true
  end

  # Full path to file
  def filepath( obj )
    return File.join( WeatherRipper::WEATHER_DIR, obj.provider + ".txt")
  end

  # Prepare directory structure for
  def prepare_directories( obj )
    # not needed
    # dirs are prepared elsewhere
  end
  
end
