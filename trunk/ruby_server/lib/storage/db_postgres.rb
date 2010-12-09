require 'singleton'
require 'rubygems'
require 'pg' # pg gem, newer than postgres gem probably

class DbPostgres
  include Singleton

  def store( obj )
  end
end
