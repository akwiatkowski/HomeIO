require 'lib/db_store'
require 'lib/usart'
require 'lib/home_io_meas_element_offline'
require 'lib/home_io_meas_element_online'

# Stores all information about one type of measurement
class HomeIoMeasElement
  include HomeIoMeasElementOffline
  include HomeIoMeasElementOnline

  attr_reader :code, :measurements, :dbstore, :offline, :comm

  # max measurements array size
  MAX_MEASUREMENTS_ARRAY_SIZE = 10

  def initialize
    init
  end

  # Initialize not necessary values
  def init
    # current transformation could be later different than default
    @transformation[:scaler] = @transformation[:default_scaler] if @transformation[:scaler].nil? and not @transformation[:default_scaler].nil?
    @transformation[:offset] = @transformation[:default_offset] if @transformation[:offset].nil? and not @transformation[:default_offset].nil?

    # seed for simulation purpose
    @offline[:seed] = rand( OFFLINE_MAX_SEED )
    @offline[:range] = @offline[:max_value] - @offline[:min_value]

    # used for first storing
    @dbstore[:time] = Time.now

    # standard raw value is a single number
    if @comm[:single_value_response].nil?
      @comm[:single_value_response] = true
    end
  end

  # Starts retrieving and storing measurements
  def start
    start_retrieve
    start_store
  end

  # Stop retrieving and storing measurements
  def stop
    @retrieve_thread.kill
    @store_thread.kill
  end

  # Transform raw to real value
  def transform_raw( raw_value )
    return (raw_value + @transformation[:offset]).to_f * @transformation[:scaler]
  end

  private

  # Start new thread for fetching measurements
  def start_retrieve
    @retrieve_thread = Thread.new do
      # fetching will be in loop
      loop do
        # sleep and retrieve value
        sleep( @comm[:refresh_interval] )
        retrieve
      end
    end
  end

  # Start new thread for storing data
  def start_store
    @store_thread = Thread.new do
      # fetching will be in loop
      loop do
        sleep( @comm[:refresh_interval] )
        if need_to_store? == true
          store
        end
      end
    end
  end

  # Retrieve now value of measurement
  def retrieve
    outcome = Usart.instance.retrieve( self )
    after_retrieve( outcome )
  end

  # Add value hash to last measurements array
  def add_to_measurements( h )
    @measurements << h

    # remove first if array is too big
    while @measurements.size > MAX_MEASUREMENTS_ARRAY_SIZE
      @measurements.shift
    end

  end

  # After retrieving data from uC add to list
  def after_retrieve( outcome )
    add_to_measurements({
      :time => Time.now,
      :value => transform_raw( outcome[:raw] ),
      :raw_value => outcome[:raw],
      :online => outcome[:online],
      :offset => @transformation[:offset],
      :scaler => @transformation[:scaler]
    })
  end

  # Check if this measurement has to be stored
  def need_to_store?
    last = @measurements.last
    # no value - no store
    return false if last.nil?
    # no store information - store
    return true if @dbstore[:time].nil? or @dbstore[:value].nil?

    # stored earlier than dbstore[:max_interval] seconds ago
    if ( last[:time].to_f - @dbstore[:time].to_f ) >= @dbstore[:max_interval].to_f
      return true
    end

    # stored later than dbstore[:min_interval] seconds ago
    if ( last[:time].to_f - @dbstore[:time].to_f ) <= @dbstore[:min_interval].to_f
      return false
    end

    # significant value change
    last_value = last[:value].to_f
    last_stored_value = @dbstore[:value].to_f
    if last[:online] == true
      # real values
      if (last_value - last_stored_value).abs >= @dbstore[:sig_change]
        return true
      else
        return false
      end
      
    else
      # simulaton
      if (last_value - last_stored_value).abs >= @offline[:sig_change]
        return true
      else
        return false
      end

    end

  end

  # Store value in DB
  def store
    # add to base / save query into file

    # at start it could be nil
    if @dbstore.nil?
      @dbstore = Hash.new
    end

    # store it in DB or file
    DbStore.instance.store_meas_element( self )

    # mark as stored
    @dbstore[:time] = @measurements.last[:time]
    @dbstore[:value] = @measurements.last[:value]
  end

end
