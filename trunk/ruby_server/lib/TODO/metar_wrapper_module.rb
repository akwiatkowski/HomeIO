require './lib/comm_wrapper.rb'

require './lib/metar_tools.rb'
require './lib/metar_logger.rb'
require './lib/metar_queue.rb'
require './lib/metar_server.rb'
require './lib/metar_cron.rb'

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
