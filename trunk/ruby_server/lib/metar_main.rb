require 'lib/metar_tools'
require 'lib/metar_logger'
#require 'lib/metar_tcp_server'

require 'lib/metar_queue'
require 'lib/metar_server'
require 'lib/metar_cron'

Thread.abort_on_exception = true

config = MetarTools.load_config

# wątek logujący
m = MetarLogger.new( config )

# kolejka poleceń
mq = MetarQueue.new
mq.set_references({:metar_logger => m})
mq.start
# serwer TCP, port domyslny
ms = MetarServer.new( mq, config[:tcp_port] )
ms.start

# wątek cron'owski
mc = MetarCron.new( mq )

Thread.abort_on_exception = true

loop do
  sleep( 30 )
end