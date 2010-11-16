require 'open-uri'
require 'logger'

require 'lib/metar_tools'
require 'lib/metar_logger_base'
require 'lib/metar_program_log'

#require 'lib/metar_code'
require 'lib/db_store'

# Klasa zajmuje się utworzeniem wątku logującego pogodę korzystając z
# serwerów METAR
#
# Metody związane z ogólnym działaniem, sterowaniem

class MetarLogger < MetarLoggerBase
  attr_reader :cities

  SLEEP_EVERY_URL_OPEN = 60

  # Ustawienie miast które będzie ściągało
  def initialize( opts = {} )

    super( opts )

    # jakie miasta będą logowane
    @cities = opts[:cities]
    cits = @cities.collect{|c| "#{c[:code]} (#{c[:name].to_s})"}
    puts "Cities: #{cits.join(", ")}"

    # gdy jest true to oznacza że serwer uruchomi kolejną pętle
    @start_new_loop = false
    # gdy true oznacza że serwer aktualnie pracuje
    @is_running = false

    # co jaki czas ściągać dane
    @sleep_every_url_open = SLEEP_EVERY_URL_OPEN
    @sleep_every_url_open = opts[:sleep_every_url_open].to_i if not opts[:sleep_every_url_open].nil?
    puts "Interval: #{@sleep_every_url_open}"

    # process and store in DB after logging?
    @instant_process = opts[:instant_process]
    if true == @instant_process
      require 'lib/metar_code'
      require 'lib/db_store'
    end

    # start z pliku konfiguracyjnego
    if opts[:start] == true
      start
    end

  end

  # Uruchamia serwer logujący METAR
  def start
    return {:status => :failed, :operation => :start} if not @start_new_loop == false or not @is_running == false

    @start_new_loop = true
    MetarProgramLog.log.info("Start command received at #{Time.now.to_human}")
    
    @thread = Thread.new{ start_new_thread }

    return {:status => :ok, :operation => :start}
  end

  # Kończy działanie serwera
  def stop
    return {:status => :failed, :operation => :stop} if not @is_running == true

    MetarProgramLog.log.info("Stop command received at #{Time.now.to_human}")
    @start_new_loop = false

    return {:sCatus => :ok, :operation => :stop}
  end

  # Fetch only one time
  def do_once
    year = Time.now.year
    month = Time.now.month

    @cities.each do |c|
      metar = download_metar( c[:code] )
      status = store_metar( metar, c[:code] )
      puts "1 - #{c[:code]} - #{c[:name]} #{" - was new" if status == true }"
      if true == @instant_process and true == status
        mc = MetarCode.new
        mc.process( metar, year, month )
        c[:city] = c[:name]
        DbStore.instance.store_metar_data( mc.decoded_to_weather_db_store, c) if mc.valid?
      end


      metar = download_metar_2( c[:code] )
      status = store_metar( metar, c[:code] )
      puts "2 - #{c[:code]} - #{c[:name]} #{" - was new" if status == true }"
      if true == @instant_process and true == status
        mc = MetarCode.new
        mc.process( metar, year, month )
        c[:city] = c[:name]
        DbStore.instance.store_metar_data( mc.decoded_to_weather_db_store, c) if mc.valid?
      end

      metar = download_metar_3( c[:code] )
      status = store_metar( metar, c[:code] )
      puts "3 - #{c[:code]} - #{c[:name]} #{" - was new" if status == true }"
      if true == @instant_process and true == status
        mc = MetarCode.new
        mc.process( metar, year, month )
        c[:city] = c[:name]
        DbStore.instance.store_metar_data( mc.decoded_to_weather_db_store, c) if mc.valid?
      end

      metar = download_metar_4( c[:code] )
      status = store_metar( metar, c[:code] )
      puts "4 - #{c[:code]} - #{c[:name]} #{" - was new" if status == true }"
      if true == @instant_process and true == status
        mc = MetarCode.new
        mc.process( metar, year, month )
        c[:city] = c[:name]
        DbStore.instance.store_metar_data( mc.decoded_to_weather_db_store, c) if mc.valid?
      end
    end

    # send to db all non saved
    DbStore.instance.flush
  end

  # Zwraca status działania serwera
  def status
    return {
      :start_new_loop => @start_new_loop,
      :is_running => @is_running
    }
  end

  private

  # Wątek serwera logującego METAR
  def start_new_thread

    # aby tylko można było 1 uruchomić
    return if @is_running == true
    @is_running = true

    puts "STARTING SERVER"

    while(@start_new_loop) do

      # pasek statusu - jakie miasta mają nową pogodę, jakie nie
      @status_bar = ""

      @cities.each do |c|
        #puts "LOOP #{c}"
        metar = download_metar( c[:code] )
        status = store_metar( metar, c[:code] )
        metar = download_metar_2( c[:code] )
        status = store_metar( metar, c[:code] )

        if status == true
          @status_bar += "+"
        else
          @status_bar += "-"
        end

      end

      # wyświetlaj pasek statusu
      puts "CITIES: #{@status_bar}"
      sleep( @sleep_every_url_open )

    end

    puts "STOPING SERVER"
    @is_running = false
    MetarProgramLog.log.info("Stop command completed at #{Time.now.to_human}")
    Thread.pass


  end

  



end
