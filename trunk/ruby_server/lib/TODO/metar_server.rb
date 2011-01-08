require './lib/comm_server.rb'

class HomeIoServer < CommServer

  # port dla serwera METAR
  PORT = 20001
  @@port = PORT
end
