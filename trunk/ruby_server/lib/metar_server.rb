require 'lib/comm_server'

class MetarServer < CommServer

  # port dla serwera METAR
  PORT = 20001
  @@port = PORT
end
