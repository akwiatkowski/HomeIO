require 'singleton'
require './lib/utils/core_classes.rb'
require './lib/storage/storage.rb'
require './lib/utils/geolocation.rb'
#require './lib/utils/dev_info.rb'

# Abstract class to all storage classes

class StorageDbAbstract

  SQL_DIR = File.join(
    'lib',
    'storage',
    'sqls'
  )

  def initialize
    load_config
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

  # Prepare main directories
  def init
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
