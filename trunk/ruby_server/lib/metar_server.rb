require './lib/comm_server.rb'

class MetarServer < CommServer

  # port dla serwera METAR
  PORT = 20001
  @@port = PORT
end
