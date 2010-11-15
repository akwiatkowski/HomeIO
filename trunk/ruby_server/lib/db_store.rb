# for time formatting
require 'rubygems'

require 'mysql'
require 'sqlite3'

require 'singleton'
require 'lib/config_loader'
require 'lib/dev_info'
require 'lib/usart'

# Saves measurements into DB or backup txt file
class DbStore
  include Singleton

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
    @@sqlite_db_file_weather = @@config[:sq_lite_file_weather]
    @@sqlite_db_file_metar_weather = @@config[:sq_lite_file_metar_weather]
    @@sqlite_metar_queries = Array.new

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
    sqlite_setup

    # backup query file
    @@query_file = @@config[:query_file]
    # logger
    @@logger = Logger.new( @@config[:logger_path] )

  end

  # Create sqlite dbs and tables
  def sqlite_setup

    # TODO table for meas
    @sqlite_db_meas = SQLite3::Database.new( @@sqlite_db_file_meas )
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
    @sqlite_db_weather = SQLite3::Database.new( @@sqlite_db_file_weather )
    t_wa = "CREATE TABLE IF NOT EXISTS weather_archives(
  id INTEGER PRIMARY KEY,
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
    @sqlite_db_metar_weather = SQLite3::Database.new( @@sqlite_db_file_metar_weather )
    t_wma = "CREATE TABLE IF NOT EXISTS weather_metar_archives(
  id INTEGER PRIMARY KEY,
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
    @sqlite_db_metar_weather.execute( t_wma )

    
  end

  # Tries to store in DB, if fail store in queries in text file
  def store_meas_element( mel )
    query = create_query_for_meas( mel )
    store_by_query( query )
  end

  # TODO
  def queue_meas_element( mel )
  end
  
  # TODO
  def flush_meas_element
  end

  def store_weather_data( d, defin )
    query = create_query_for_weather( d, defin )
    # ignore bad queries, they're stored also in files
    #puts query
    t = Time.now
    store_weather_data_in_sqlite( query, d[:provider] )
    ta = Time.now
    store_by_query( query )
    tb = Time.now

    puts "sqlite #{(ta.to_f - t.to_f)*1000} mysql #{(tb.to_f - ta.to_f)*1000}"
  end

  def store_weather_data_in_sqlite( query, provider )
    if provider == 'METAR'
      base = @sqlite_db_metar_weather
      q = query.gsub(/`#{@@db_base_univ}`\./,'')
      @@sqlite_metar_queries << q

      if @@sqlite_metar_queries.size > 50
	base.execute( @@sqlite_metar_queries.join("\n") )
	@@sqlite_metar_queries = Array.new
      end

    else
      base = @sqlite_db_weather
      q = query.gsub(/`#{@@db_base_univ}`\./,'')
      base.execute( q )
    end
  end

  private

  # Execute query or store to file
  def store_by_query( q )

    # rails like status
    status = nil

    # increment store count
    # TODO to nie jest używane tylko do zapisywania pomiarów
    @@di.inc( self.class, "store_count_#{@@di_sufix}" )

    begin
      @dbh = connect
      execute_query( q, @dbh )
      status = true
      #rescue Mysql::Error => e
    rescue => e
      status = false

      @@logger.error( "Error when storing in DB" )
      @@logger.error( "#{e.inspect}" )
      @@logger.error( "#{e.backtrace}")
      execute_backup( q )
      
    ensure
      disconnect( @dbh )
		end

    return status
  end

  # Create query for inserting data
  def create_query( meas )
    return case meas.class.to_s
    when 'HomeIoMeasElement' then create_query_for_meas( meas )
    end
  end

  # Create query for inserting measurements
  def create_query_for_meas( meas )
    query =
      "INSERT INTO `#{@@db_base}`.`#{@@db_table_meas}` (`code`, `time_from`, `time_to`, `value`) VALUES (
        '#{meas.code}', '#{meas.dbstore[:time].to_f}' , '#{meas.measurements.last[:time].to_f}' , #{meas.measurements.last[:value].to_f});"

    return query
  end

  # Create SQL query for storing weather data
  def create_query_for_weather( d, defin )
    # special table for METAR data
    if d[:provider].to_s.downcase == "metar"
      table_name = @@db_table_weather_metar
    else
      table_name = @@db_table_weather
    end

    # processed hash to store also nulls
    w_data = Hash.new
    [:temperature, :wind, :pressure, :rain, :snow].each do |k|
      if d[ k ].nil?
        w_data[ k ] = "NULL"
      else
        w_data[ k ] = "'#{d[ k ]}'"
      end
    end

    # TODO sprawdzić co się stanie jak przyjdą nile
    #query = "INSERT INTO `#{@@db_base_univ}`.`#{table_name}` (
    query = "REPLACE INTO `#{@@db_base_univ}`.`#{table_name}` (
`created_at` ,
`provider` ,
`city` ,
`lat` ,
`lon` ,
`time_from` ,
`time_to` ,
`temperature` ,
`wind` ,
`pressure` ,
`rain` ,
`snow`
)
VALUES (
 '#{d[:time_created].to_i}', '#{d[:provider].to_s}', '#{defin[:city].to_s}',
 '#{defin[:coord][:lat]}', '#{defin[:coord][:lon]}',
 '#{d[:time_from].to_i}', '#{d[:time_to].to_i}',
 #{w_data[:temperature]}, #{w_data[:wind]}, #{w_data[:pressure]}, #{w_data[:rain]}, #{w_data[:snow]}
);"
    #puts query 
    return query
  end

  # Connect to DB
  def connect
    return Mysql.connect(
      @@db_host,
      @@db_login,
      @@db_password,
      @@db_base
    )
  end

  # Close connection
  def disconnect( dbh )
    dbh.close if dbh
  end

  # Execute query
  def execute_query( query, dbh )
    fix_encoding = "SET NAMES 'utf8';"
    res = dbh.query( fix_encoding )

    res = dbh.query( query )
    #puts res.inspect
    return res
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
