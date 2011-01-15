require 'singleton'
require './lib/utils/core_classes.rb'
require './lib/storage/storage.rb'
require './lib/utils/geolocation.rb'
#require './lib/utils/dev_info.rb'

# Abstract class to all storage classes
class StorageDbAbstract

  attr_reader :config

  SQL_DIR = File.join(
    'lib',
    'storage',
    'sqls'
  )

  # Show times cost of storing into DBs
  SHOW_STORAGES_TIME_INFO = true

  # Initialization - after server startup
  def initialize
    load_config
  end

  # Accesor for enabled/disabled
  def enabled
    return @config[:enabled]
  end

  # Store object
  def store( obj )
    d = get_definition( obj )
    
    if d.nil?
      # not standard storage
      other_store( obj ) 
    else
      # standarized store
      standarized_store( obj, d )
    end

  end

  # One time initialization
  def init
    raise 'Not implemented'
  end

  # Destructive rolling back initialization from method *init*
  def deinit
    raise 'Not implemented'
  end

  # Stores all buffered objects
  # Some classes doesn't need to flush
  def flush
    raise 'Not implemented'
  end

  private

  # Load this storage config
  def load_config
    @config = ConfigLoader.instance.config( self.class.to_s )
  end

  # Select definition of proper storage
  # Data like table name
  def get_definition( obj )
    # definition of storage by class
    return @config[:classes].select{|c| obj.class.to_s == c[:klass] }.first
  end

  # Store for not standard object
  def other_store( obj )
    raise 'Not implemented'
  end

  # Store standard object
  def standarized_store( obj, d )
    raise 'Not implemented'
  end


end
