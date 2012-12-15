require 'home_io_server'

if ENV["HOMEIO_ENV"] == 'dev'
  HomeIoServer::HomeIoLogger.dev_mode!(1)
end

HomeIoServer::HomeIoLogger
ws = HomeIoServer::WeatherServer.new
ws.start

loop do
  sleep 60
end
