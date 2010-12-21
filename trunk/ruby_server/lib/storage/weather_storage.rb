require 'singleton'
require './lib/utils/core_classes.rb'
require './lib/metar/metar_code.rb'
require './lib/utils/dev_info.rb'

# Basic raw weather (non-metar) storage in text files

class WeatherStorage
  include Singleton
  
  def store( obj )
    # Store only raw metars
    return nil unless obj.kind_of?( MetarCode )

    return store_metar( obj )
  end

  # Prepare main directories
  def init
    prepare_main_directories
  end

  def flush
  end


  private

  # Store METAR in files
  def store_metar( obj )
    # invalid metars won't be stored
    return :invalid unless obj.valid?

    prepare_directories( obj )
    return :was_logged unless not_logged?( obj )
    return :ok if append_metar( obj )
    return :failed
  end

  # Check if metar wasn't already logged
  def not_logged?( obj )
    fp = filepath( obj )

    if File.exists?( fp )
      f = File.open( fp, "r" )
      f.each_line do |l|
        # check every line
        if not l.index( obj.raw.strip ).nil?
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
  def append_metar( obj )
    f = File.open( filepath( obj ), "a" )
    f.puts obj.raw + "\n"
    f.close

    puts "Stored: #{obj.raw}"
    DevInfo.instance.inc( self.class.to_s, :metars_logged )

    return true
  end

  # Full path to file
  def filepath( obj )
    return File.join( dirpath( obj ), filename( obj ) )
  end

  # Filename where metar should be logged
  def filename( obj )
    return "metar_" + obj.city.to_s + "_" + obj.year.to_s2( 4 ) + "_" + obj.month.to_s2( 2 ) + ".log"
  end

  # Directory path where metar should be logged
  def dirpath( obj )
    return File.join(
      Constants::DATA_DIR,
      MetarConstants::METAR_LOG_DIR,
      obj.city,
      obj.year.to_s2( 4 )
    )
  end

  # Prepare directory structure for
  def prepare_directories( obj )
    # city directory
    metar_log_dir = File.join(
      Constants::DATA_DIR,
      MetarConstants::METAR_LOG_DIR,
      obj.city
    )
    if not File.exists?( metar_log_dir )
      Dir.mkdir( metar_log_dir )
    end

    # log year
    metar_log_dir = File.join(
      Constants::DATA_DIR,
      MetarConstants::METAR_LOG_DIR,
      obj.city,
      obj.year.to_s2( 4 )
    )
    if not File.exists?( metar_log_dir )
      Dir.mkdir( metar_log_dir )
    end
  end

  # Prepare main directories
  def prepare_main_directories
    if not File.exists?( Constants::DATA_DIR )
      Dir.mkdir( Constants::DATA_DIR )
    end

    d = File.join(
      Constants::DATA_DIR,
      MetarConstants::METAR_LOG_DIR
    )
    if not File.exists?( d )
      Dir.mkdir( d )
    end
  end



  # Zapisuje METAR
  def _save_metar( datahash )

    # jeśli plik istnieje to sprawdza czy nie ma już w nim tej linijki
    
    # jeżeli pliku nie ma lub nie ma w nim wpisu dodanie wpisu na koniec
    

    # zapisanie jako ostatni do wykorzystania
    @last_metars[ datahash[:city] ] = datahash

    # poprawnie dodane jako nowe
    return true

  end







end
