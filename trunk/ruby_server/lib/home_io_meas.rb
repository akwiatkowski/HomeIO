require 'singleton'
require './lib/home_io_meas_element.rb'
require './lib/config_loader.rb'


# Przechowuje informacje o pomiarach
class HomeIoMeas
  include Singleton

  def initialize
    @@config = ConfigLoader.instance.config( self.class )
    @@measurements = @@config[:defs]

    prepare_db

    # initialize not essential values
    @@measurements.each do |m|
      m.init
    end

    @@DEV_INFO_STORE_FILE = @@config[:store_file_path]
    @@AUTOSAVE_INTERVAL = @@config[:autosave_interval]
  end

  def info
    #puts @@config.inspect
    @@measurements.first.store
    @@measurements.first.retrieve
  end

  # Return clone of measurements (to not modify it accidentaly)
  def measurements
    return @@measurements.clone
  end

  #private

  # Stars thread fetching measurements from uC
  def thread_fetch
    @@measurements.each do |m|
      m.start
    end
  end

  private

  # Check and recreate measurements dictionary
  def prepare_db

  end

end
