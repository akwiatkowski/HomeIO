require 'open-uri'
require './lib/metar_tools.rb'
require './lib/metar_logger_base.rb'
require './lib/metar_program_log.rb'
require './lib/metar_ripper/metar_ripper.rb'

# Klasa bazowa zawierająca podstawowe funkcję dla każdego loggera
#
# Metody głównie związane z pobieraniem i zapisywaniem

class MetarLoggerBase

  def initialize( opts = {} )

    # tu będą przechowywane ostatnie metary
    @last_metars = Hash.new

    # TODO dodać hash do ilość pobranych, różnych
    # inkrementowane .to_i + 1

    # utworzenie podstawowych katalogów
    MetarTools.check_dirs
  end

  # Fetch and store metar for city
  # Use all sites
  def fetch_and_store_city( metar_city )
    year = Time.now.year
    month = Time.now.month

    # fetch metars
    m = MetarRipper.instance
    o = m.fetch( metar_city )

    # process them
    # *metar_array* - array of processed metars
    metar_array = MetarCode.process_array( o , year, month )

    # store them
    metar_array.each do |ma|
      ma.store
    end

    puts metar_array.inspect
  end
  

  # Przygotowuje METAR do zapisu
  def store_metar( metar, city )
    return if metar.nil? or city.nil?

    # wyszukanie czasu w METAR
    if metar =~ /(\d{2})(\d{2})(\d{2})Z/

      h = Hash.new

      # mamy dzień i godzinę z pliku
      h[:day] = $1.to_i
      h[:hour] = $2.to_i
      h[:minute] = $3.to_i

      # oraz miesiac i rok z aktualnej daty uniwersalnej
      t = Time.now.getutc
      h[:year] = t.year
      h[:month] = t.month

      # miasto
      h[:city] = city

      # wyciągnięcie pełnego kodu METAR

      if metar =~ /^.*$\n^(.*)$/

        h[:metar] = $1
        save_metar( h )

      else
        MetarProgramLog.log.error("Cant decode metar: '#{metar}', city '#{city}'")
      end

      #puts h.inspect
      #puts t.inspect


    else
      MetarProgramLog.log.error("Cant decode time: '#{metar}', city '#{city}'")
    end
  end

  # Zapisuje METAR
  def save_metar( datahash )

    # najpierw miasto
    metar_log_fir = File.join(
      MetarTools::DATA_DIR,
      MetarTools::METAR_LOG_DIR,
      datahash[:city].to_s
    )
    if not File.exists?( metar_log_fir )
      Dir.mkdir( metar_log_fir )
    end

    # później rok
    metar_log_fir = File.join(
      MetarTools::DATA_DIR,
      MetarTools::METAR_LOG_DIR,
      datahash[:city].to_s,
      datahash[:year].to_s2(4)
    )
    if not File.exists?( metar_log_fir )
      Dir.mkdir( metar_log_fir )
    end

    file_name = MetarTools.log_filename(
      datahash[:city],
      datahash[:year],
      datahash[:month]
    )

    # jeśli plik istnieje to sprawdza czy nie ma już w nim tej linijki
    if File.exists?( file_name )
      f = File.open( file_name, "r" )
      f.each_line do |l|
        # jeżeli istnieje to nie będzie wpisywane
        return false if datahash[:metar].strip == l.strip
      end
      f.close
    end
    # jeżeli pliku nie ma lub nie ma w nim wpisu dodanie wpisu na koniec
    f = File.open( file_name, "a" )
    f.puts datahash[:metar] + "\n"
    puts datahash[:metar] + "\n"
    f.close

    # zapisanie jako ostatni do wykorzystania
    @last_metars[ datahash[:city] ] = datahash

    # poprawnie dodane jako nowe
    return true

  end

end