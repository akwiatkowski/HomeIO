require 'singleton'

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
      DbMysql.instance,
      DbPostgres.instance
    ]

    @storages.each do |s|
      s.init
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

  private


end
