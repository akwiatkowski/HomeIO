require 'singleton'
require 'rubygems'
require 'mysql'

class DbMysql
  include Singleton

  def store( obj )
  end

  # Init storage
  def init
  end
end
