require 'home_io_server'

if true or ENV["HOMEIO_ENV"] == 'dev'
  HomeIoServer::HomeIoLogger.dev_mode!(1)
end

ws = HomeIoServer::MeasServer.new
ws.start

sleep 120