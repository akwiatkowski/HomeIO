# for time formatting
require 'rubygems'

require 'mysql'
require 'sqlite3'

require 'singleton'

require './lib/config_loader.rb'
require './lib/dev_info.rb'
require './lib/usart.rb'
require './lib/metar_tools.rb'
require './lib/geolocation.rb'


# Saves measurements into DB or backup txt file
class DbStore
  include Singleton

  SQLITE_BUSY_TIMEOUT = 20_000

  def initialize
    @@config = ConfigLoader.instance.config( self.class )
    @@di = DevInfo.instance

    @@is_online = Usart.instance.is_online?

    # DB parameters
    @@db_host = @@config[:db_host]
    @@db_login = @@config[:db_login]
    @@db_password = @@config[:db_password]
    # table for storing measurements
    @@db_table_meas = @@config[:db_table_meas]
    # non-metar weather conditions
    @@db_table_weather = @@config[:db_table_weather]
    # metar weather conditions
    @@db_table_weather_metar = @@config[:db_table_weather_metar]

    # sqlite dbs
    @@sqlite_db_file_meas = @@config[:sq_lite_file_meas]
    @@sqlite_meas_pool = Array.new
    @@sqlite_db_file_weather = @@config[:sq_lite_file_weather]
    @@sqlite_weather_pool = Array.new
    @@sqlite_db_file_metar_weather = @@config[:sq_lite_file_metar_weather]
    @@sqlite_metar_pool = Array.new

    # choose DB depends on online mode
    if @@is_online == true
      @@db_base = @@config[:db_base_online]
      @@di_sufix = "online"
    else
      @@db_base = @@config[:db_base_offline]
      @@di_sufix = "offline"
    end

    # universal DB
    @@db_base_univ = @@config[:db_base]

    # backup query file
    @@query_file = @@config[:query_file]
    # logger
    @@logger = Logger.new( @@config[:logger_path] )

  end

  # Tries to store in DB now, if fail store queries in text file
  def store_meas_element( meas_element, force = false )
    query =  create_query_data_for_meas( meas_element )
    @@sqlite_meas_pool << query
    flush_if_needed_meas( force )
  end

  def store_weather_data( d, defin, force = false )
    query = create_query_data_for_weather( d, defin )
    @@sqlite_weather_pool << query
    flush_if_needed_weather( force )
  end

  def store_metar_data( d, defin, force = false )
    query = create_query_data_for_metar( d, defin )
    @@sqlite_metar_pool << query
    flush_if_needed_metar( force )
  end

  def flush
    #puts @@sqlite_metar_pool.inspect
    flush_if_needed_meas( true )
    flush_if_needed_weather( true )
    flush_if_needed_metar( true )
  end

  # Create new sqlite DB, tables, and populate cities
  def prepare_sqlite_db
    sqlite_connect
    sqlite_prepare_db_structure
    sqlite_disconnect
  end

  private

  # Create query data for inserting measurements
  def create_query_data_for_meas( meas )
    return {
      :db => {
        :db => @@db_base,
        :table => @@db_table_meas,
      },
      :data => {
        :code => meas.code,
        :time_from => meas.dbstore[:time].to_f,
        :time_to => meas.measurements.last[:time].to_f,
        :value => meas.measurements.last[:value].to_f
      },
      :options => {
        :ignore => false,
        :type => 'meas'
      }
    }
  end

  # Create query data for storing weather data
  def create_query_data_for_weather( d, defin )
    # processed hash to store also nulls
    w_data = Hash.new
    [:temperature, :wind, :pressure, :rain, :snow].each do |k|
      if d[ k ].nil?
        w_data[ k ] = "NULL"
      else
        w_data[ k ] = "'#{d[ k ]}'"
      end
    end

    return {
      :db => {
        :db => @@db_base_univ,
        :table => @@db_table_weather,
      },
      :data => {
        :created_at => d[:time_created].to_i,
        :provider => "'" + d[:provider].to_s + "'",
        :city => "'" + defin[:city].to_s + "'",
        :lat => defin[:coord][:lat],
        :lon => defin[:coord][:lon],
        :time_from => d[:time_from].to_i,
        :time_to => d[:time_to].to_i,
        :temperature => w_data[:temperature],
        :wind => w_data[:wind],
        :pressure => w_data[:pressure],
        :rain => w_data[:rain],
        :snow => w_data[:snow]
      },
      :options => {
        :ignore => true,
        :type => 'weather'
      }
    }

    #return "INSERT INTO `#{@@db_base_univ}`.`#{@@db_table_weather}` (
    #return "INSERT INTO #{@@db_table_weather} (
  end

  # Create SQL query for storing metar data
  def create_query_data_for_metar( d, defin )
    # processed hash to store also nulls
    w_data = Hash.new
    [:temperature, :wind, :pressure, :rain, :snow].each do |k|
      if d[ k ].nil?
        w_data[ k ] = "NULL"
      else
        w_data[ k ] = "'#{d[ k ]}'"
      end
    end

    return {
      :db => {
        :db => @@db_base_univ,
        :table => @@db_table_weather_metar,
      },
      :data => {
        :created_at => d[:time_created].to_i,
        :city_id => defin[:id].to_i,
        :time_from => d[:time_from].to_i,
        :time_to => d[:time_to].to_i,
        :temperature => w_data[:temperature],
        :wind => w_data[:wind],
        :pressure => w_data[:pressure],
        :rain => w_data[:rain],
        :snow => w_data[:snow],
        :raw => "'" + d[:raw].to_s.gsub(/\'/,"\\\\"+'\'') + "'"
      },
      :options => {
        :ignore => true,
        :type => 'metar'
      }
    }
  end

  # Remove databas name
  #def convert_mysql_query_to_sqlite( q )
  #  return q.gsub(/`#{@@db_base_univ}`\./,'').gsub(/`#{@@db_base}`\./,'').gsub(/INSERT IGNORE INTO/,"INSERT INTO")
  #end

  def flush_if_needed_meas( force )
    if force or @@sqlite_meas_pool.size >= @@config[:db_table_meas_query_autoflush]
      execute_inserts( @@sqlite_meas_pool )
      @@sqlite_meas_pool = Array.new
    end
  end

  def flush_if_needed_weather( force )
    if force or @@sqlite_weather_pool.size >= @@config[:db_table_weather_query_autoflush]
      execute_inserts( @@sqlite_weather_pool )
      @@sqlite_weather_pool = Array.new
    end
  end

  def flush_if_needed_metar( force )
    if force or @@sqlite_metar_pool.size >= @@config[:db_table_weather_metar_query_autoflush]
      execute_inserts( @@sqlite_metar_pool )
      @@sqlite_metar_pool = Array.new
    end
  end

  # Execute insert like query
  def execute_inserts( data )
    # robi sql, wykonuje dla mysql (jak bład to do pliku i return), sqlite, jak błąd to do logach

    if data.size == 0
      # nothing to do
      return true
    end

    # rails like status
    status = nil

    # increment store count - number of insert like queries
    sufix = @@di_sufix.to_s
    begin
      sufix += "_#{data.first[:options][:type]}"
    rescue
    end
    @@di.inc( self.class, "store_count_#{sufix}" )

    mysql_time = Time.now

    # storing into mysql
    begin
      # store into mysql
      @dbh = mysql_connect

      fix_encoding = "SET NAMES 'utf8';"
      @dbh.query( fix_encoding )
      trsql = "START TRANSACTION;"
      @dbh.query( trsql )

      # create mysql query
      q = mysql_process_to_sql( data )
      mysql_execute_query( q, @dbh )

      trsql = "COMMIT;"
      @dbh.query( trsql )

      # rescue Mysql::Error => e
    rescue => e
      status = false

      @@logger.error( "Error when storing in DB" )
      @@logger.error( "#{e.inspect}" )
      @@logger.error( "#{e.backtrace}")
      execute_backup( q )

      puts "DB ERROR"
      return status
    ensure
      mysql_disconnect( @dbh )
		end

    sqlite_time = Time.now

    # storing into sqlite
    begin
      sqlite_connect

      base = case data.first[:options][:type]
      when 'meas' then @@sqlite_db_meas
      when 'weather' then @@sqlite_db_weather
      when 'metar' then @@sqlite_db_metar_weather
      end

      base.execute( "BEGIN TRANSACTION;" )
      
      # create mysql query
      q = sqlite_process_to_sql( data )
      # puts q
      base.execute_batch( q )

      base.execute( "COMMIT;" )

      sqlite_disconnect

      #rescue Mysql::Error => e
    rescue => e
      status = false

      @@logger.error( "Error when storing in DB - sqlite" )
      @@logger.error( "#{e.inspect}" )
      @@logger.error( "#{e.backtrace}")

      puts "DB ERROR - SQLITE"
      return status
    ensure
      # sqlite_disconnect
		end

    puts " * mysql time #{(sqlite_time.to_f - mysql_time.to_f)*1000}, sqlite time #{(Time.now.to_f - sqlite_time.to_f)*1000}"


    status = true
    return status
  end

  # Connect to DB
  def mysql_connect
    return Mysql.connect(
      @@db_host,
      @@db_login,
      @@db_password,
      @@db_base
    )
  end

  # Close connection
  def mysql_disconnect( dbh )
    dbh.close if dbh
  end

  # Process data to mysql query
  def mysql_process_to_sql( data )

    ignore = ""
    if data.first[:options][:ignore] == true
      ignore = "IGNORE "
    end

    q = "INSERT #{ignore} INTO `#{data.first[:db][:db]}`.`#{data.first[:db][:table]}` "
    # table columns
    data_keys = data.first[:data].keys
    q += "(#{data_keys.collect{|c| "`#{c}`"}.join(',')}) VALUES "

    # data values
    values = Array.new
    data.each do |d|
      tmp_vals = Array.new

      # insert all values for 1 record
      data_keys.each do |k|
        tmp_vals << "#{d[:data][k]}"
      end

      # join it
      values << "(" + tmp_vals.join(',') + ")"
    end

    q += values.join(',')
    q += ";"

    return q
  end

  # Execute query
  def mysql_execute_query( query, dbh )
    res = dbh.query( query )
    return res
  end



  
  # Connect and create DBs if needed
  def sqlite_connect
    @@sqlite_db_meas = SQLite3::Database.new( @@sqlite_db_file_meas )
    @@sqlite_db_meas.busy_timeout( SQLITE_BUSY_TIMEOUT )

    # weather archive
    @@sqlite_db_weather = SQLite3::Database.new( @@sqlite_db_file_weather )
    @@sqlite_db_weather.busy_timeout( SQLITE_BUSY_TIMEOUT )

    # metar
    @@sqlite_db_metar_weather = SQLite3::Database.new( @@sqlite_db_file_metar_weather )
    @@sqlite_db_metar_weather.busy_timeout( SQLITE_BUSY_TIMEOUT )
  end

  # Prepare tables, populate cities
  def sqlite_prepare_db_structure
    t_m = "CREATE TABLE IF NOT EXISTS meas_archives(
  id INTEGER PRIMARY KEY,
  code TEXT,
  time_from REAL,
  time_to REAL,
  value REAL,
  UNIQUE (code, time_from) ON CONFLICT ABORT
);"
    @@sqlite_db_meas.execute( t_m )

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
    @@sqlite_db_weather.execute( t_wa )

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
    @@sqlite_db_metar_weather.execute( t_wma )

    # metar cities, used also for normal cities
    t_wma_c = "CREATE TABLE IF NOT EXISTS cities(
  id INTEGER PRIMARY KEY,
  name TEXT,
  country TEXT,
  metar TEXT,
  lat REAL,
  lon REAL,
  calculated_distance REAL,
  UNIQUE (metar) ON CONFLICT IGNORE,
  UNIQUE (lat,lon) ON CONFLICT IGNORE
);"
    @@sqlite_db_weather.execute( t_wma_c )
    @@sqlite_db_metar_weather.execute( t_wma_c )

    # populate metar cities
    cq = "BEGIN TRANSACTION;"
    @@sqlite_db_weather.execute( cq )
    @@sqlite_db_metar_weather.execute( cq )

    config = MetarTools.load_config
    config[:cities].each do |c|
      distance = Geolocation.distance( c[:coord][:lat], c[:coord][:lon] )
      cq = "insert into cities (id,name,country,metar,lat,lon,calculated_distance) values (#{c[:id]},'#{c[:name].gsub(/\'/,'')}','#{c[:country].to_s.gsub(/\'/,'')}','#{c[:code]}',#{c[:coord][:lat]},#{c[:coord][:lon]},#{distance});\n"

      #@@sqlite_db_weather.execute( cq )
      @@sqlite_db_metar_weather.execute( cq )
    end

    cq = "COMMIT;"
    @@sqlite_db_weather.execute( cq )
    @@sqlite_db_metar_weather.execute( cq )

  end

  # Close sqlite
  def sqlite_disconnect
    @@sqlite_db_meas.close unless @@sqlite_db_meas.closed?
    @@sqlite_db_weather.close unless @@sqlite_db_weather.closed?
    @@sqlite_db_metar_weather.close unless @@sqlite_db_metar_weather.closed?
  end

  def sqlite_process_to_sql( data )
    #    s = mysql_process_to_sql( data )
    #    s.gsub!(/IGNORE/, '')
    #    s.gsub!(/`#{data.first[:db][:db]}`\./,'')
    #    return s

    q = ""
    data.each do |d|
      q += "INSERT INTO `#{d[:db][:table]}` "

      data_keys = d[:data].keys
      q += "(#{data_keys.collect{|c| "`#{c}`"}.join(',')}) VALUES "

      values = Array.new
      data_keys.each do |k|
        values << "#{d[:data][k]}"
      end

      q += "(" + values.join(',') + ");\n"
    end

    return q
  end

  # Store in backup file
  def execute_backup( query )

    f = File.new( @@query_file, "a")
    f.puts( query )
    f.close

    # increment store count
    @@di.inc( self.class, "store_backup_count_#{@@di_sufix}" )

  end





 
end
