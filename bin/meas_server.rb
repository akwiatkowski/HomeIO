require 'home_io_server'

if ENV["HOMEIO_ENV"] == 'dev'
  HomeIoServer::HomeIoLogger.dev_mode!(1)
end

ws = HomeIoServer::MeasServer.new

sleep 50