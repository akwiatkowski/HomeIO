# TODO mutex when adding to pool

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

    @pool = Array.new
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
    when 'Weather' then store_weather( obj )
    else other_store( obj )
    end

    # flushing
    if @pool.size >= @config[:pool_size].to_i
      flush
    end
  end

  def flush
    # saving each object
    puts "StorageActiveRecord flushing #{@pool.size} objects"
    ActiveRecord::Base.transaction do
      @pool.each do |o|
        res = o.save

        if res == false
          err_msg = "StorageActiveRecord errors: #{o.errors.inspect}"
          puts err_msg
          AdvLog.instance.logger( self ).warn( "#{err_msg}   -   #{o.inspect}" )
          # TODO move it outside, more type of error handling
        end
      end
    end

    # clearing pool
    @pool = Array.new
  end

  private

  def store_metar( obj )
    # wrong records can be not saved - there are always raw metars in text files
    return unless obj.valid?
    h = {
      :time_from => obj.output[:time],
      :time_to => obj.output[:time] + MetarCode::TIME_INTERVAL,
      :temperature => obj.output[:temperature],
      :pressure => obj.output[:pressure],
      :wind => obj.output[:wind_mps],
      :snow_metar => obj.output[:snow_metar],
      :rain_metar => obj.output[:rain_metar],
      :raw => obj.raw,
      :city_id => obj.city_id,
    }
    # updating metar if stored in DB
    wma = WeatherMetarArchive.find(:last, :conditions => {:city_id => obj.city_id, :time_from => obj.output[:time], :raw => obj.raw} )
    if wma.nil?
      wma = WeatherMetarArchive.new( h )
    else
      wma.update_attributes( h )
    end
    
    @pool << wma
  end

  def store_weather( obj )
    # wrong records can be not saved - there are always raw metars in text files
    return unless obj.valid?
    h = {
      :time_from => obj.data[:time_from],
      :time_to => obj.data[:time_to],
      :temperature => obj.data[:temperature],
      :pressure => obj.data[:pressure],
      :wind => obj.data[:wind],
      :snow => obj.data[:snow],
      :rain => obj.data[:rain],
      :city_id => obj.defin[:id],
      :weather_provider_id => obj.data[:weather_provider_id]
    }
    # updating metar if stored in DB
    wa = WeatherArchive.find(
      :last,
      :conditions => {
        :city_id => obj.defin[:id],
        :time_from => obj.data[:time_from],
        :weather_provider_id => obj.data[:weather_provider_id]
      }
    )
    
    if wa.nil?
      wa = WeatherArchive.new( h )
    else
      wa.update_attributes( h )
    end

    @pool << wa
  end

end
