require './lib/storage/storage_db_abstract.rb'
require 'rubygems'
require 'active_record'
require 'singleton'

# better way to load all models from dir, + migrations
Dir["./lib/storage/active_record/models/*.rb"].each {|file| require file }
Dir["./lib/storage/active_record/*.rb"].each {|file| require file }

# Storage using custom active record connection
# Just like the Rails :)
#
# Store every object instantly, no pooling

class StorageActiveRecord < StorageDbAbstract
  include Singleton

  def initialize
    super

    ActiveRecord::Base.establish_connection(
      @config[:connection]
    )
  end

  def init
    ActiveRecordInitMigration.up
  end

  def deinit
    ActiveRecordInitMigration.down
  end

  # Store object
  def store( obj )
    case obj.class.to_s
    when 'MetarCode' then store_metar( obj )
    else other_store( obj )
    end
  end

  private

  def store_metar( obj )
    WeatherMetarArchive.create!({
      :time_from => obj.output[:time],
      :time_to => obj.output[:time] + MetarCode::TIME_INTERVAL,
      :temperature => obj.output[:temperature],
      :pressure => obj.output[:pressure],
      :wind => obj.output[:wind_mps],
      :snow_metar => obj.output[:snow_metar],
      :rain_metar => obj.output[:rain_metar],
      :raw => obj.raw,
      :city_id => obj.city_id,
    })
  end

end
