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


require 'singleton'
require 'rubygems'
require 'sqlite3'
require './lib/storage/storage_db_abstract.rb'

# Fast sql based storage engine

class DbSqlite < StorageDbAbstract
  include Singleton

  # wait 20 seconds if db is busy
  SQLITE_BUSY_TIMEOUT = 20_000
  # where dbs are located
  SQLITE_DIR = File.join(
    Constants::DATA_DIR,
    'sqlite'
  )

  VERBOSE = false

  # @config - configuration file
  # @db - hash for

  #
  def initialize
    super
    init_pools
  end

  # Init storage
  def init
    connect
    init_db_structure
    disconnect
  end

  # Delete all sqlite files
  def deinit
    [ :db_file_meas, :db_file_weather, :db_file_metar_weather ].each do |s|
      fname = sqlite_filename( @config[ s ] )
      begin
        File.delete( fname )
      rescue
        puts "error at #{fname}"
      end
    end
  end

  def store( obj )
    case obj.class.to_s
      # TODO add here object which use module StorageInterface
    when 'MetarCode', 'Weather' then store_object( obj )
    else other_store( obj )
    end
  end

  # Force all flush
  def flush
    @config[:classes].keys.each do |k|
      flush_by_type( k )
    end
  end


  private

  # Create all pools
  def init_pools
    @pools = Hash.new
    @config[:classes].keys.each do |k|
      @pools[ k ] = Array.new
    end
  end

  def store_object( obj )
    # use class name as key
    k = obj.class.to_s.to_sym
    @pools[ k ] << obj

    # check if needed flush
    if @pools[ k ].size >= @config[:classes][ k ][:pool_size]
      # flush
      flush_by_type( k )
    end
  end

  # Store all from buffer
  #
  # *k* - class name in symbol
  def flush_by_type( k )

    puts "Sqlite flushing #{k}, #{ @pools[ k ].size } objects"
    t = Time.now

    queries = Array.new
    @pools[ k ].each do |o|
      queries << convert_obj_to_query( @config[:classes][ k ], o )
    end

    # fresh connection
    connect
    # db in use
    db = @db[ k ]
    q = "BEGIN TRANSACTION;"
    db.execute( q )

    queries.each do |q|
      # verbose mode
      puts q if VERBOSE
      db.execute( q )
    end

    q = "COMMIT;"
    db.execute( q )
    disconnect

    puts "#{self.class.to_s} - storing #{@pools[ k ].size} object - #{Time.now.to_f - t.to_f} s" if SHOW_STORAGES_TIME_INFO

    # clear pool
    @pools[ k ] = Array.new
  end

  # Converts storable object to sqlite query
  #
  # *conf* - hash from config of obj class
  # *obj* - object to store
  def convert_obj_to_query( conf, obj )
    db_data = obj.to_db_data

    q = ""
    q += "insert into #{conf[:table_name]} ("
    q += db_data[:columns].collect{|c| c.to_s}.join(",")
    q += ") values ("
    #q += db_data[:columns].collect{|c| db_data[:data][ c ] }.join(",")
    q += db_data[:columns].collect{|c| escape_string( db_data[:data][ c ].to_s ) }.join(",")
    q += ");"

    # verbose mode
    puts q if VERBOSE

    return q
  end

  # Escape slashes to sqlite
  def escape_string( str )
    return 'NULL' if str.to_s == ''
    
    #s = str.to_s.gsub(/'/,"\\\\\\\\"+"\\\\\'")
    # http://www.sqlite.org/faq.html#q14
    s = str.to_s.gsub(/'/,"''")
    s = s.gsub(/^''/,"'")
    s = s.gsub(/''$/,"'")
    return s
  end


  def flush_metar
    queries = Array.new
    @pool_metar.each do |m|

    end
  end

  # Store for not standard object
  def other_store( obj )
    raise 'This object can not be stored'
  end

  


  # Store standard object
  def standarized_store( obj, d )
    puts obj.inspect, d.inspect
    raise 'Not implemented'
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

    @db = {
      :MetarCode => @sqlite_db_metar_weather,
      :Weather => @sqlite_db_weather,
      # TODO add here other storable classes
    }
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
    t_wma = "CREATE TABLE IF NOT EXISTS #{@config[:classes][:MetarCode][:table_name]}(
  id INTEGER PRIMARY KEY,
  city_id INTEGER,
  created_at INTEGER,
  time_from INTEGER,
  time_to INTEGER,
  temperature REAL,
  wind REAL,
  pressure REAL,
  rain_metar INTEGER,
  snow_metar INTEGER,
  raw TEXT,
  UNIQUE (city_id, time_from, time_to) ON CONFLICT IGNORE
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
      cq = "insert into cities (id,name,country,metar,lat,lon,calculated_distance) values (#{c[:id]},'#{escape_string( c[:name] )}','#{escape_string( c[:country])}','#{c[:code]}',#{c[:coord][:lat]},#{c[:coord][:lon]},#{distance});\n"
      # puts cq
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

  # Create queries to store all needed objects
end
