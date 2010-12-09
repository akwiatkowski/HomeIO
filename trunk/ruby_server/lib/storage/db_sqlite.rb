require 'singleton'
require 'rubygems'
require 'sqlite3'
require './lib/storage/storage_db_abstract.rb'

class DbSqlite < StorageDbAbstract
  include Singleton

  # wait 20 seconds if db is busy
  SQLITE_BUSY_TIMEOUT = 20_000
  # where dbs are located
  SQLITE_DIR = File.join(
    Constants::DATA_DIR,
    'sqlite'
  )

  # Init storage
  def init
    connect
    init_db_structure
    disconnect
  end

  private

  # Store for not standard object
  def other_store( obj )
    puts obj.inspect
  end

  # Store standard object
  def standarized_store( obj, d )
    puts obj.inspect, d.inspect
  end

  # Create directories if needed, return url
  def sqlite_filename( db_name )
    # tworzenie katalogów
    if not File.exists?( Constants::DATA_DIR )
      Dir.mkdir( Constants::DATA_DIR )
    end

    if not File.exists?( SQLITE_DIR )
      Dir.mkdir( SQLITE_DIR )
    end
    
    return File.join( SQLITE_DIR, "#{db_name}.sqlite" )
  end

  # Connect
  def connect
    @sqlite_db_meas = SQLite3::Database.new( sqlite_filename( @config[ :db_file_meas ] ) )
    @sqlite_db_meas.busy_timeout( SQLITE_BUSY_TIMEOUT )

    # weather archive
    @sqlite_db_weather = SQLite3::Database.new( sqlite_filename( @config[ :db_file_weather ] ) )
    @sqlite_db_weather.busy_timeout( SQLITE_BUSY_TIMEOUT )

    # metar
    @sqlite_db_metar_weather = SQLite3::Database.new( sqlite_filename( @config[ :db_file_metar_weather ] ) )
    @sqlite_db_metar_weather.busy_timeout( SQLITE_BUSY_TIMEOUT )
  end

  # Create tables
  def init_db_structure
    t_m = "CREATE TABLE IF NOT EXISTS meas_archives(
  id INTEGER PRIMARY KEY,
  code TEXT,
  time_from REAL,
  time_to REAL,
  value REAL,
  UNIQUE (code, time_from) ON CONFLICT ABORT
);"
    @sqlite_db_meas.execute( t_m )

    # weather archive
    t_wa = "CREATE TABLE IF NOT EXISTS weather_archives(
  id INTEGER PRIMARY KEY,
  city_id INTEGER,
  created_at REAL,
  provider TEXT,
  city TEXT,
  lat REAL,
  lon REAL,
  time_from REAL,
  time_to REAL,
  temperature REAL,
  wind REAL,
  pressure REAL,
  rain REAL,
  snow REAL,
  UNIQUE (provider, city, time_from, time_to) ON CONFLICT IGNORE
);"
    @sqlite_db_weather.execute( t_wa )

    # metar
    t_wma = "CREATE TABLE IF NOT EXISTS weather_metar_archives(
  id INTEGER PRIMARY KEY,
  city_id INTEGER,
  created_at REAL,
  provider TEXT,
  city TEXT,
  lat REAL,
  lon REAL,
  time_from REAL,
  time_to REAL,
  temperature REAL,
  wind REAL,
  pressure REAL,
  rain REAL,
  snow REAL,
  raw TEXT,
  UNIQUE (provider, city, time_from, time_to) ON CONFLICT IGNORE
);"
    @sqlite_db_metar_weather.execute( t_wma )

    # metar cities, used also for normal cities
    t_wma_c = "CREATE TABLE IF NOT EXISTS cities(
  id INTEGER PRIMARY KEY ON CONFLICT IGNORE,
  name TEXT,
  country TEXT,
  metar TEXT,
  lat REAL,
  lon REAL,
  calculated_distance REAL,
  UNIQUE (metar) ON CONFLICT IGNORE,
  UNIQUE (lat,lon) ON CONFLICT IGNORE
);"
    @sqlite_db_weather.execute( t_wma_c )
    @sqlite_db_metar_weather.execute( t_wma_c )

    # populate metar cities
    cq = "BEGIN TRANSACTION;"
    @sqlite_db_weather.execute( cq )
    @sqlite_db_metar_weather.execute( cq )

    cities = ConfigLoader.instance.config( MetarConstants::CONFIG_TYPE )[:cities]
    cities.each do |c|
      distance = Geolocation.distance( c[:coord][:lat], c[:coord][:lon] )
      cq = "insert into cities (id,name,country,metar,lat,lon,calculated_distance) values (#{c[:id]},'#{c[:name].gsub(/\'/,'')}','#{c[:country].to_s.gsub(/\'/,'')}','#{c[:code]}',#{c[:coord][:lat]},#{c[:coord][:lon]},#{distance});\n"
      puts cq
      @sqlite_db_metar_weather.execute( cq )
    end

    cq = "COMMIT;"
    @sqlite_db_weather.execute( cq )
    @sqlite_db_metar_weather.execute( cq )

    # TODO: dopisać metodę która ściąga listę wszystkich miast dla zwykłego ściągania pogody
    # łączy je, dodaje id, nadpisuje plik konfiguracyjny z idkami

    # TODO możnaby nadpisać również odległości :)

  end

  # Close sqlite
  def disconnect
    @sqlite_db_meas.close unless @sqlite_db_meas.closed?
    @sqlite_db_weather.close unless @sqlite_db_weather.closed?
    @sqlite_db_metar_weather.close unless @sqlite_db_metar_weather.closed?
  end
end
