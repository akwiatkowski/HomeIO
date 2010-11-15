require 'open-uri'
require 'logger'

require 'lib/metar_tools'
require 'lib/metar_program_log'

# Uruchamia co pewien czas przetwarzanie danych

class MetarCron
  #INTERVAL = 5
  # TODO przerzuć do pliku kondifuracyjnego
  INTERVAL = 24*3600 # dobowo

  def initialize( metar_queue )

    @mq = metar_queue

    # pętla, odpalanie przetwarzania
    start_loop

    MetarProgramLog.log.info("MetarCron: Started")

  end

  private

  def start_loop
    Thread.new{ one_loop  }
  end

  def one_loop

    loop do

      sleep( INTERVAL )
      puts "CRON"

      MetarProgramLog.log.info("MetarCron: Doing")

      @mq.process_server_command({
          :command => :create_graph_everything
        })

    end

  end

end
