require 'singleton'
require 'rubygems'
require 'pg' # pg gem, newer than postgres gem probably

# http://oldmoe.blogspot.com/2008/07/faster-io-for-ruby-with-postgres.html

class DbPostgres
  include Singleton

  def store( obj )
  end

  # Init storage
  def init
  end
end
