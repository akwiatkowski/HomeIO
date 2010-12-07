require 'yaml'
require 'date'

# Metody narzędziowe, różne
# TODO, czy warto zamienić na singleton?

# TODO: wyrzucić config z tej klasy

class MetarTools

  # tutaj będą wszystkie wyjścia programu
  DATA_DIR = "data"
  # logs dir
  LOGS_DIR = File.join( DATA_DIR, "logs" )

  # czyste logi
  METAR_LOG_DIR = "metar_log"
  # przetworzone dane
  OUTPUT_DIR = "output"
  # wykresy
  OUTPUT_GRAPH_DIR = "graphs"

  # plik konfiguracyjny serwera pogodowego
  CONFIG_FILE = "config/metar.yml"

  # Wczytaj plik konfiguracyjny
  def self.load_config
    @@config = YAML::load_file( CONFIG_FILE )
    @@cities = @@config[:cities]
    @@graph_types = @@config[:data_process_directives].keys
    @@is_verbose = @@config[:is_verbose]
    return @@config
  end
  
  # Zwraca typy wszystkich możliwych wykresów
  # [:temperature, :wind, ...]
  def self.graph_types
    self.load_config if @@graph_types.nil?
    return @@graph_types
  end

  # Return cities configuration
  # [{:code => "EPPO", :name => "Poznań, ...}, ...]
  def self.log_cities
    self.load_config if @@cities.nil?
    return @@cities
  end

  # Return if verbose
  def self.is_verbose?
    self.load_config if @@is_verbose.nil?
    return @@cities
  end

  # Zwraca czasy logów dla miasta
  # Return all log times for city
  #
  # {year => [month, month], year => [month]}
  def self.log_times_for_city( city )

    # TODO można użyć tam gdzie przetwarza się "wszystko"

    output = Hash.new

    # search years
    fd = File.join(
      MetarTools::DATA_DIR,
      MetarTools::METAR_LOG_DIR,
      city.to_s
    )
    if not File.exist?( fd )
      return output
    end

    d = Dir.new( fd )

    years = d.entries.select{ |e| e =~ /\d{4}/ }.sort

    # przeszukuj po latach
    # search in years
    years.each do |y|

      # adding new year
      output[y] = Array.new

      d = Dir.new( File.join(
          MetarTools::DATA_DIR,
          MetarTools::METAR_LOG_DIR,
          city.to_s,
          y.to_s
        ))

      # nazwy plików zgodne z wzorcem
      # filename correct with pattenr
      files = d.entries.select { |f| f =~ /metar_[A-Z]{4}_\d{4}_\d{2}.log/  }.sort

      files.each do |f|

        # pobranie dodatkowych parametrów - miesiac
        if f =~ /metar_([A-Z]{4})_(\d{4})_(\d{2}).log/

          year = $2.to_i
          month = $3.to_i

          output[y] << month

        end
      end
    end

    return output

  end

  # Tworzy katalogi potrzebne do działania programu
  def self.check_dirs
    if not File.exists?(DATA_DIR)
      Dir.mkdir(DATA_DIR)
    end

    dir = File.join( DATA_DIR, METAR_LOG_DIR)

    if not File.exists?( dir )
      Dir.mkdir( dir )
    end

    dir = File.join( DATA_DIR, OUTPUT_DIR)

    if not File.exists?( dir )
      Dir.mkdir( dir )
    end


    dir = File.join( DATA_DIR, OUTPUT_GRAPH_DIR)

    if not File.exists?( dir )
      Dir.mkdir( dir )
    end

  end

  # Zwraca miejsce pliku logów
  def self.log_filename( city, year, month)
    return File.join(
      DATA_DIR,
      METAR_LOG_DIR,
      city.to_s,
      year.to_s2(4),
      "metar_" + city.to_s + "_" + year.to_s2(4) + "_" + month.to_s2(2) + ".log"
    )
  end

  # Zwraca miejsce dla pliku wyjścia
  def self.output_filename( city, year, month)
    return File.join(
      DATA_DIR,
      OUTPUT_DIR,
      city.to_s,
      year.to_s2(4),
      "output_" + city.to_s + "_" + year.to_s2(4) + "_" + month.to_s2(2) + ".yml"
    )
  end

  # Zwraca miejsce dla pliku wyjścia
  def self.output_graph_filename( city, year, month, which)
    return File.join(
      DATA_DIR,
      OUTPUT_GRAPH_DIR,
      city.to_s,
      year.to_s2(4),
      which.to_s + "_" + city.to_s + "_" + year.to_s2(4) + "_" + month.to_s2(2) + ".png"
    )
  end

  # Sprawdza i tworzy katalogi dla wyjścia
  def self.check_output( city, year )
    dir = File.join(
      DATA_DIR,
      OUTPUT_DIR,
      city.to_s
    )

    if not File.exists?( dir )
      Dir.mkdir( dir )
    end

    dir = File.join(
      DATA_DIR,
      OUTPUT_DIR,
      city.to_s,
      year.to_s2(4)
    )

    if not File.exists?( dir )
      Dir.mkdir( dir )
    end


  end

  # Sprawdza i tworzy katalogi dla wyjścia - wykresu
  def self.check_output_graph( city, year )
    dir = File.join(
      DATA_DIR,
      OUTPUT_GRAPH_DIR,
      city.to_s
    )

    if not File.exists?( dir )
      Dir.mkdir( dir )
    end

    dir = File.join(
      DATA_DIR,
      OUTPUT_GRAPH_DIR,
      city.to_s,
      year.to_s2(4)
    )

    if not File.exists?( dir )
      Dir.mkdir( dir )
    end


  end





end


# Nowe metody do wyświetlania
class Object

  # Wypełnij zerami aż do długości
  def to_s2( places )
    tmp = self.to_s

    while( tmp.size < places )
      tmp = "0" + tmp
    end

    return tmp
  end

  def to_s_round( places )
    if self.nil?
      return nil
    end
    
    tmp = ( self * (10 ** places ) ).round.to_f
    tmp /= (10.0 ** places )
    return tmp
  end

end

class String

  # Odkodowanie co oznacza dany kod METAR - jakie miasto
  def encode_metar_name
    c = MetarTools.load_config
    o = c[:cities].select{|city| city[:code] == self}
    if o.size == 1
      return o.first[:name]
    else
      return self
    end
  end
end


class Time

  # Nowa metoda wyświetlania czasu
  def to_human
    return self.strftime("%Y-%m-%d %H-%M-%S")
  end

end

class Date

  # Obliczanie ostatniego dnia miesiąca
  def self.last_day_of_the_month yyyy, mm
    d = new yyyy, mm
    d += 42                  # warp into the next month
    new(d.year, d.month) - 1 # back off one day from first of that month
  end

end

class Time

  # Ustawia początek danego miesiąca
  def utc_begin_of_month
    t = Time.utc( self.year, self.month, 1, 0, 0, 0)
    #puts "* " + t.to_s
    return t
  end

  # Ilość dni w miesiącu
  def self.days_in_month( month, year = Time.now.year )
    return ((Date.new(year, month, 1) >> 1) - 1).day
  end

  # Ustawia koniec danego miesiąca
  def utc_end_of_month
    days = Time.days_in_month( self.month )
    t = Time.utc( self.year, self.month, days, 0, 0, 0)
    # przejdź na koniec danego dnia
    t += 24*3600 - 1
    #puts "- " + t.to_s
    return t
  end

end
