$:.unshift(File.dirname(__FILE__))

require './config/environment.rb'

require 'home_io_server/ugly_stuff'
require 'home_io_server/home_io_logger'
require 'home_io_server/redis_proxy'
require 'home_io_server/storage'
require 'home_io_server/meas_server'
require 'home_io_server/weather_server'

module HomeIoServer
end