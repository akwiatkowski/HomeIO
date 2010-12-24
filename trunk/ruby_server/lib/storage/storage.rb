require 'singleton'
require './lib/utils/constants.rb'

# better way to load all files from dir
Dir["./lib/storage/*.rb"].each {|file| require file }

# Rips raw metar from various sites

class Storage
  include Singleton

  attr_reader :klasses

  def initialize
    @storages = [
      MetarStorage.instance,
      DbSqlite.instance,
      #DbMysql.instance,
      #DbPostgres.instance
      StorageActiveRecord.instance
    ]
  end

  # One time initialization
  def init
    @storages.each do |s|
      s.init
    end
  end

  # One time destructive uninitialization
  def deinit
    # TODO insert warning or sth
    @storages.each do |s|
      s.deinit
    end
  end

  # Store object wherever it is possible
  def store( obj )
    store_outputs = Array.new
    @storages.each do |s|
      store_outputs << s.store( obj )
    end
    return store_outputs
  end

  # Flush all storage classes
  def flush
    @storages.each do |s|
      s.flush
    end
  end

  private


end