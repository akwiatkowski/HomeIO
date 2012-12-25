require 'home_io_server'

if true or ENV["HOMEIO_ENV"] == 'dev'
  HomeIoServer::HomeIoLogger.dev_mode!(1)
end

MeasReceiver::CommProtocol.host = '192.168.0.13'
MeasReceiver::CommProtocol.port = '2002'

ws = HomeIoServer::MeasServer.new
ws.start

loop do
  sleep 60
end