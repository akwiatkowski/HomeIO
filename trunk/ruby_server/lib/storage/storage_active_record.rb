require './lib/storage/storage_db_abstract.rb'
require 'rubygems'
require 'active_record'
require 'singleton'

# better way to load all models from dir
Dir["./lib/storage/models/*.rb"].each {|file| require file }

# Storage using custom active record connection
# Just like the Rails :)

class StorageActiveRecord < StorageDbAbstract
  include Singleton

  def initialize
    super

    ActiveRecord::Base.establish_connection(
      @config[:connection]
    )

    puts City.all.inspect
  end
end
