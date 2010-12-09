require './lib/metar_tools.rb'
require './lib/metar_logger.rb'
#require './lib/metar_tcp_server.rb'

require './lib/metar_queue.rb'
require './lib/metar_server.rb'
require './lib/metar_cron.rb'

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