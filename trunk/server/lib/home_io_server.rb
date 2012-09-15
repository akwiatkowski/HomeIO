$:.unshift(File.dirname(__FILE__))

require 'rufus/scheduler'

require 'home_io_server/redis_proxy'
require 'home_io_server/meas_server'
require 'home_io_server/weather_server'

module HomeIoServer
end