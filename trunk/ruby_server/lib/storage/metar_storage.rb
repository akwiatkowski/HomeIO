require 'singleton'
require './lib/utils/core_classes.rb'
require './lib/metar/metar_code.rb'
require './lib/utils/dev_info.rb'

# Basic raw metar storage in text files

class MetarStorage
  include Singleton
  
  def store( obj )
    # Store only raw metars
    return nil unless obj.kind_of?( MetarCode )
    # Store only freshly downloaded
    return nil unless MetarConstants::METAR_CODE_JUST_DOWNLOADED == obj.type

    return store_metar( obj )
  end

  # Prepare main directories
  def init
    prepare_main_directories
  end

  def deinit
    # wont be implemented!
  end

  def flush
  end

  # Raw storage - always enabled
  def enabled
    return true
  end



  # Full path to file
  def self.filepath( city, year, month )
    return File.join( self.dirpath( city, year ), self.filename( city, year, month ) )
  end

  # Filename where metar should be logged
  def self.filename( city, year, month )
    return "metar_" + city.to_s + "_" + year.to_s2( 4 ) + "_" + month.to_s2( 2 ) + ".log"
  end

  # Directory path where metar should be logged
  def self.dirpath( city, year )
    return File.join(
      Constants::DATA_DIR,
      MetarConstants::METAR_LOG_DIR,
      city,
      year.to_s2( 4 )
    )
  end

  # Get all cities
  def self.cities_logged
    dpath = File.join(
      Constants::DATA_DIR,
      MetarConstants::METAR_LOG_DIR
    )
    d = Dir.new( dpath )
    a = Array.new

    d.each do |f|
      unless f == '..' or f == '.'
        # get all cities
        a << f
      end
    end

    return a
  end

  # Get all months where are metar logs for city
  def self.dirs_per_city( city )
    dpath = File.join(
      Constants::DATA_DIR,
      MetarConstants::METAR_LOG_DIR,
      city
    )
    d = Dir.new( dpath )

    h = Hash.new

    # check all years
    d.each do |f|
      unless f == '..' or f == '.'
        # get all month per year
        h[ f ] = self.files_for_city_year( city, f )
      end
    end

    return h
  end

  # Get all months where are metar logs for city and year
  def self.files_for_city_year( city, year )
    dpath = self.dirpath( city, year )
    d = Dir.new( dpath )

    a = Array.new

    # check all years
    d.each do |f|
      if f =~ /_(\d{2})\.log/
        a << $1
      end
    end

    return a
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
    #return self.class.filepath( obj )
  end

  # Filename where metar should be logged
  def filename( obj )
    #return "metar_" + obj.city.to_s + "_" + obj.year.to_s2( 4 ) + "_" + obj.month.to_s2( 2 ) + ".log"
    return self.class.filename( obj.city, obj.year, obj.month )
  end

  # Directory path where metar should be logged
  def dirpath( obj )
    #    return File.join(
    #      Constants::DATA_DIR,
    #      MetarConstants::METAR_LOG_DIR,
    #      obj.city,
    #      obj.year.to_s2( 4 )
    #    )
    return self.class.dirpath( obj.city, obj.year )
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



  # XXX delete it and test
  # Zapisuje METAR
  def __save_metar( datahash )

    # jeśli plik istnieje to sprawdza czy nie ma już w nim tej linijki
    
    # jeżeli pliku nie ma lub nie ma w nim wpisu dodanie wpisu na koniec
    

    # zapisanie jako ostatni do wykorzystania
    @last_metars[ datahash[:city] ] = datahash

    # poprawnie dodane jako nowe
    return true

  end







end
