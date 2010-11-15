# Klasa nadzorująca dany proces, można sieciową killować i ponownie uruchamiać

require 'lib/comm'
#require 'lib/comm_server'

class CommWrapper < Comm
  DEBUG_VERBOSE = false

  # Zapisuje definicje podserwerów którymi będzie się opiekował
  def initialize( defs )
    @threads = Hash.new
    @defs = defs
  end

  # Uruchamia wszystkie zdefiniowane wątki
  def start_threads
    @defs.each do |d|
      start_thread( d )
    end

    start_monitor
  end

  # Sprawdzenie czy dany podserwer odpowiada na ping
  def check_ping( d )

    port = d[:tcp_port]
    # wysyła pinga
    resp = send_to_server( :ping, port )
    if resp == :ok
      # jest dobrze
      return true
    end

    # coś nie tak
    return false
  end

  # Informacje do eksportu o podserwerach
  def export
    e = Hash.new

    @defs.each do |d|
      e[ d[:name] ] = d.merge({
        :status => @threads[ d[:name].to_sym ].status
      })
    end

    return e
  end

  private

  # Uruchamia określony wątek
  def start_thread( d )
    @threads[ d[:name].to_sym ] = Thread.new do
      # uruchamiam określoną metodę
      self.send( d[:method] )
    end

    # czas uruchomienia
    d[:start_time] = Time.now
  end

  # Uruchamia wątek analizujący
  def start_monitor
    loop do
      sleep(5)

      puts "MONITOR" if DEBUG_VERBOSE

      @defs.each do |d|

        status = @threads[ d[:name].to_sym ].status
        puts "S #{status}" if DEBUG_VERBOSE
        if status == nil or status == false or not check_ping( d ) == true
          start_thread( d )

          # czas wykrzaczenia
          d[:fail_time] = Time.now
        end
      end


    end
  end


end
