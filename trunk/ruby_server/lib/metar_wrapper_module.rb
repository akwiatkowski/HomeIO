require 'lib/comm_wrapper'

require 'lib/metar_tools'
require 'lib/metar_logger'
require 'lib/metar_queue'
require 'lib/metar_server'
require 'lib/metar_cron'

# Moduł metody startującej serwer METAR
module MetarWrapperModule

  private

  # Uruchomienie serwera METAR
  def thread_metar
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

    loop do
      sleep(60)
    end

  end

end
