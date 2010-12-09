require 'singleton'
require 'yaml'
require './lib/utils/config_loader.rb'

# Store and periodically saves development informations
# At start reload from stored file
class DevInfo
  include Singleton

  # Load previously stored dev info
  def initialize
    # loaded from config file
    @@config = ConfigLoader.instance.config( self.class )
    @@DEV_INFO_STORE_FILE = @@config[:store_file_path]
    @@AUTOSAVE_INTERVAL = @@config[:autosave_interval]
    
    self_load
    new_thread
  end

  # Increament key
  def inc( klass, key )
    # prefer symbol
    klass = klass.to_s.to_sym
    key = key.to_s.to_sym

    if @@dev_info[ klass ].nil? or @@dev_info[ klass ][ key].nil?
      # need to create first
      create_empty_fixnum( klass, key )
    end

    @@dev_info[ klass ][ key ] += 1
  end

  # Get data as hash
  def [](klass)
    klass = klass.to_s.to_sym

    if @@dev_info[ klass ].nil?
      @@dev_info[ klass ] = Hash.new
    end
    
    return @@dev_info[ klass ]
  end

  # Force saving dev info
  def force_save
    self_save
  end

  # Force loading
  def force_load
    self_load
  end

  # Filename and path of dev info file
  def file_name
    return @@DEV_INFO_STORE_FILE
  end

  # Autosave interval
  def autosave_interval
    return @@AUTOSAVE_INTERVAL
  end

  private

  # Create 0-value entry
  def create_empty_fixnum( klass, key )
    if @@dev_info[ klass ].nil?
      @@dev_info[ klass ] = Hash.new
    end

    @@dev_info[ klass ][ key ] = 0
  end

  # Load info
  def self_load
    if File.exist?( @@DEV_INFO_STORE_FILE )
      @@dev_info = YAML::load_file( @@DEV_INFO_STORE_FILE )
      # sometime there is error - blank file
      @@dev_info = Hash.new if not @@dev_info.kind_of?( Hash )

      # increment load count
      inc( self.class, :load_count )
    else
      @@dev_info = Hash.new

      # set creation time
      self[ self.class ][:created_at] = Time.now
    end
  end

  # Save info
  def self_save
    File.open( @@DEV_INFO_STORE_FILE, 'w' ) do |out|
      YAML.dump( @@dev_info, out )
    end

    inc( self.class, :save_count )
    self[ self.class ][ :last_save ] = Time.now
  end

  # Thread saving every interval
  def new_thread
    # new thread
    Thread.new do
      loop do
        # wait interval
        sleep @@AUTOSAVE_INTERVAL
        self_save

        inc( self.class, :autosave_count )
      end
    end
  end

end
