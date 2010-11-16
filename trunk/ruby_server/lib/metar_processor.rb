require 'yaml'
require 'lib/metar_tools'
require 'lib/metar_code'
require 'lib/metar_graph'
require 'lib/metar_program_log'

require 'lib/db_store'


class MetarProcessor
  HISTOGRAM_DEFAULT_LEVELS = 20

  def self.prepare
    MetarTools.check_dirs
  end

# TODO przeniesc tworzenie katalogow do innej metody, odpalanej w wielu sytuacjach

  # Przetwarza wszystkie logi dla miasta
  def self.process_city( city )
    self.prepare

    # wyszukaj lata
    dn = File.join(
        MetarTools::DATA_DIR,
        MetarTools::METAR_LOG_DIR,
        city.to_s)
  
    return unless File.exists?( dn )
    d = Dir.new( File.join(
        MetarTools::DATA_DIR,
        MetarTools::METAR_LOG_DIR,
        city.to_s
      ))

    years = d.entries.select{ |d| d =~ /\d{4}/ }.sort

    # przeszukuj po latach
    years.each do |y|

      d = Dir.new( File.join(
          MetarTools::DATA_DIR,
          MetarTools::METAR_LOG_DIR,
          city.to_s,
          y.to_s
        ))

      # nazwy plików zgodne z wzorcem
      files = d.entries.select { |f| f =~ /metar_[A-Z]{4}_\d{4}_\d{2}.log/  }.sort

      files.each do |f|

        # pobranie dodatkowych parametrów - miesiac
        if f =~ /metar_([A-Z]{4})_(\d{4})_(\d{2}).log/

          year = $2.to_i
          month = $3.to_i

          # konkretne przetworzenie pliku
          process({
              :city => city,
              :year => year,
              :month => month
            })
        end
      end
    end
  end

  # Przetworzenie logu z jednego miesiąca
  def self.process( command )
    self.prepare

    city = command[:city]
    year = command[:year]
    month = command[:month]

    puts "process #{city} #{year} #{month}"

    # plik wejściowy
    file_name = MetarTools.log_filename( city, year, month)
    
    # if file doesn't exist return empty array
    return [] if not File.exist?( file_name )

    # if exist process it
    f = File.open(file_name, "r")

    MetarTools.check_output( city, year )

    # przetworzone dane
    proc_data = Array.new

    # przetworzenie
    mc = MetarCode.new

    # moja wersja uniq!
    lines = Array.new
    f.each_line do |l|
      lines << l.strip
    end
    f.close
    lines.uniq!

    line_count = 0

    lines.each do |l|
      processed_metar = mc.process( l, year, month )

      # TODO wrzucić do pliku konfiguracyjnego i zaifować
      # TODO przydałby się singleton!!!
      Thread.abort_on_exception = true # poszukać czy nie ma rescue gdzieś
      cities = MetarTools.log_cities
      city_defin = cities.select{|c| c[:code] == city}.first
      city_defin[:city] = city_defin[:name]
      DbStore.instance.store_metar_data( mc.decoded_to_weather_db_store, city_defin )
      

      #proc_data << processed_metar

      # uniq na czas
      if proc_data.size == 0 or not proc_data.last[:time_unix] == processed_metar[:time_unix] and
          proc_data << processed_metar
      end

      line_count += 1
      if (line_count % 100) == 0
        puts "...done lines - #{line_count}"
      end
      
    end


    # zapisanie wyjścia jako YAML
    file_output = MetarTools.output_filename( city, year, month)
    fo = File.new( file_output, "w")
    YAML::dump( proc_data, fo)
    fo.close

    return proc_data

  end

  # Stworzenie wykresu
  def self.create_graph( command )
    self.prepare

    # utworzenie katalogów gdy nie ma
    MetarTools.check_output_graph( 
      command[:city],
      command[:year]
    )

    # przetworzenie danych dla pewności
    proc_data = process( command )

    mg = MetarGraph.new
    mg.create_graph( 
      proc_data,
      command
    )

    # stworzenie grafiki
    return :ok
  end

  # Stworzenie wszystkich wykresów, nawet już istniejących
  def self.create_graph_all( command, force_refresh = true )
    self.prepare

    # TODO korzystaj metod z Metartools wyszukujących

    which = command[:which]

    config = MetarTools.load_config

    # pętla po miastach
    cities = config[:cities].sort{|c,d| c[:code] <=> d[:code] }
    #puts cities.inspect, "\n\n"
    cities.each do |city|

      # wyszukaj lata
      d = Dir.new( File.join(
          MetarTools::DATA_DIR,
          MetarTools::METAR_LOG_DIR,
          city[:code].to_s
        ))

      years = d.entries.select{ |d| d =~ /\d{4}/ }.sort

      # przeszukuj po latach
      years.each do |y|

        d = Dir.new( File.join(
            MetarTools::DATA_DIR,
            MetarTools::METAR_LOG_DIR,
            city[:code].to_s,
            y.to_s
          ))

        # nazwy plików zgodne z wzorcem
        files = d.entries.select { |f| f =~ /metar_[A-Z]{4}_\d{4}_\d{2}.log/  }.sort

        files.each do |f|

          # pobranie dodatkowych parametrów - miesiac
          if f =~ /metar_([A-Z]{4})_(\d{4})_(\d{2}).log/

            year = $2.to_i
            month = $3.to_i

            # konkretne przetworzenie pliku
            begin
              c = command
              c.merge!({
                  :city => city[:code],
                  :year => year,
                  :month => month,
                  :which => which,
                  :options => command[:options]
                })

              # gdy jest wymuszenie lub wykresy nie są aktualne
              if force_refresh == true or is_mature?( command, false ) == false
                create_graph( c )
              end

              
            rescue => e
              MetarProgramLog.log.error("Faile creating graph\n#{command.inspect}\n#{e.inspect}")
            end
          end
        end
      end
    end

    return :ok
  end

  # Stworzenie wykresów, wszystkie rodzaje, ale nie tworzy pownie tych które już są
  def self.create_graph_everything( command = nil )
    self.prepare

    MetarProgramLog.log.info("CreateGraphEverything: Started")

    # pusty hasz z pustymi opcjami
    command = {:options => {} }

    types = MetarTools.graph_types

    types.each do |t|
      # odpalenie wykresów
      c = command.merge({:which => t})
      create_graph_all( c, false )
      #puts t.inspect
    end

    MetarProgramLog.log.info("CreateGraphEverything: Finish")

  end

  # Sprawdza czy wykres istnieje i czy jest już wystarczająco dojrzały - czy
  # nie jest potrzebne tworzenie go ponownie
  #
  # +command+ - command
  # +wo_graph+ - don't check graph file
  def self.is_mature?( command, wo_graph = true )

    # TODO sprawdzić gdzie jest używana i dopisać tam gdzie jest przy wykresach

    # czas końca danego miesiąca
    time_month_end = Time.mktime(
      command[:year],
      command[:month],
      1
    ) + 31*24*3600

    # sprawdzi wszystkie pliki z tej tabeli
    files = Array.new
    
    # przetworzone
    files << MetarTools.output_filename(
      command[:city],
      command[:year],
      command[:month]
    )

    # chart
    if wo_graph == false and not command[:which].nil?
      files << MetarTools.output_graph_filename(
        command[:city],
        command[:year],
        command[:month],
        command[:which]
      )
    end
    
    
    files.each do |f|
      
      if File.exist?(f) == false
        return false
      end

      m_time = File.mtime( f )
      # gdy czas końca miesiąca jest później niż czas modyfikacji to znaczy
      # że był stworzony przed końcem i należy stworzyć od nowa
      if time_month_end >= m_time
        return false
      end
    end

    # jest dobrze, nie trzeba tworzyć od nowa
    return true

  end

  # Search and return weather for city for time
  #
  # :range
  def self.get_weather( command )
    
    # default range
    if command[:range].nil?
      command[:range] = 3600
    end

    city = command[:city]

    # processing to unix time
    time = command[:time_human]
    if time =~ /(\d{4})-(\d{1,2})-(\d{1,2}) (\d{2}):(\d{2})/
      time = Time.mktime(
        $1.to_i,
        $2.to_i,
        $3.to_i,
        $4.to_i,
        $5.to_i
      )

      # if both files don't exist we can't do anything
      metar_file = MetarTools.log_filename(city, time.year, time.month)
      yaml_file = MetarTools.output_filename( city, time.year, time.month)
      if not File.exist?( metar_file ) and not File.exist?( yaml_file )
        return :file_not_exist
      else

        # if yaml doens't exist we can create it or if it is not mature
        command_process = {
          :city => city,
          :year => time.year,
          :month => time.month
        }
        if not File.exist?( yaml_file ) or is_mature?( command_process, true ) == false
          process( command_process )
        end

        # load processed data
        data = YAML::load_file( yaml_file )

        # TODO przenieś do parametru
        time_from = time.to_i - command[:range]
        time_to = time.to_i + command[:range]

        # select only near
        d_new = data.select{ |d| d[:time_unix] >= time_from and d[:time_unix] <= time_to }

        return d_new
      
      end

    else
      return :wrong_time_format
    end

  end

  # Get statistic by month
  def self.month_statistics( command )

    city = command[:city]
    which = command[:which]
    times = MetarTools.log_times_for_city( city )

    # histograms how much levels
    levels = command[:levels]
    levels = HISTOGRAM_DEFAULT_LEVELS if levels.nil?

    output = Array.new

    # search in all times
    times.keys.each do |year|
      times[year].each do |month|

        max = nil
        min = nil
        count = 0
        sum = 0.0
        # histogram
        h_levels = levels
        histogram = Array.new( h_levels, 0)

        command = {
          :city => city,
          :year => year.to_i,
          :month => month.to_i
        }
        # process if needed
        if is_mature?( command, true ) == false
          process( command )
        end

        # yaml output file
        yaml_file = MetarTools.output_filename( city, year.to_i, month.to_i)
        data = YAML::load_file( yaml_file )

        # making statistics - 1 step
        data.each do |d|

          # max
          if (max.nil? or max.to_f < d[which].to_f) and not d[which].nil?
            max = d[which].to_f
          end

          # min
          if (min.nil? or min.to_f > d[which].to_f) and not d[which].nil?
            min = d[which].to_f
          end

          # avg
          count += 1
          sum += d[which].to_f

        end

        # gdy nie ma przedziału to nie ma sensu robienia histogramu
        #if true # max.nil? or min.nil?
        if not max.nil? and not min.nil?
          # making statistics - 2 step - histogram
          h_per_level = (max.to_f - min.to_f) / h_levels

          data.each do |d|

            if not d[ which ].nil?

              # leve = (value - min) / value_per_level
              level = ( (d[ which ] - min) / h_per_level ).to_i

              if histogram[ level ].nil?
                histogram[ level ] = 1
              else
                histogram[ level ] += 1
              end
            end
          end
        end

        h = {
          :year => year.to_i,
          :month => month.to_i,
          :which => which,
          :avg => sum / count,
          :min => min,
          :max => max,
          :histogram => histogram
        }
        puts h.inspect
        output << h

      end
    end

    output.sort!{|o,p| (o[:year]*12 + o[:month]) <=> (p[:year]*12 + p[:month])}
    return output

  end

  # Get statistics by cities
  def self.cities_statistics( command )

    # which type
    which = command[:which]
    # histograms how much levels
    levels = command[:levels]
    levels = HISTOGRAM_DEFAULT_LEVELS if levels.nil?

    # output data
    output = Hash.new

    # loop for cities
    cities = MetarTools.log_cities
    cities.each do |c|

      # metar code of city
      city = c[:code]

      # all times
      times = MetarTools.log_times_for_city( city )

      # statistic data
      max = nil
      min = nil
      count = 0
      sum = 0.0
      # histogram
      h_levels = levels
      histogram = Array.new( h_levels, 0)

      # search in all times
      times.keys.each do |year|
        times[year].each do |month|

          command = {
            :city => city,
            :year => year.to_i,
            :month => month.to_i
          }

          # process if needed
          if is_mature?( command, true ) == false
            process( command )
          end
          
          # yaml output file
          yaml_file = MetarTools.output_filename( city, year.to_i, month.to_i)
          data = YAML::load_file( yaml_file )

          # making statistics - 1 step
          data.each do |d|

            # max
            if (max.nil? or max.to_f < d[which].to_f) and not d[which].nil?
              max = d[which].to_f
            end

            # min
            if (min.nil? or min.to_f > d[which].to_f) and not d[which].nil?
              min = d[which].to_f
            end

            # avg
            count += 1
            sum += d[which].to_f

          end

          # gdy nie ma przedziału to nie ma sensu robienia histogramu
          if not max.nil? and not min.nil?
            # making statistics - 2 step - histogram
            h_per_level = (max - min) / h_levels

            data.each do |d|

              if not d[ which ].nil?

                # leve = (value - min) / value_per_level
                level = ( (d[ which ] - min) / h_per_level ).to_i

                if histogram[ level ].nil?
                  histogram[ level ] = 1
                else
                  histogram[ level ] += 1
                end
              

              end
            end
          end
        end

      end

      h = {
        :name => c[:name],
        :which => which,
        :avg => sum / count,
        :min => min,
        :max => max,
        :histogram => histogram
      }
      puts h.inspect
      output[ c[:code] ] = h

    end

    return output
  end

  # Calculate energy generated by 1kW wind turbine
  def self.wind_turbine_energy( command )

    out = Array.new

    times = MetarTools.log_times_for_city( command[:city] )

    times.keys.each do |year|
      times[year].each do |month|

        # calculated data
        # {:energy => in Ws, :time => in s}
        out << wind_turbine_energy_at({
            :city => command[:city],
            :year => year.to_i,
            :month => month.to_i
          })

      end
    end

    return out
  end

  # Calculate potential wind turbine generation in month using logged data
  # or in day if day is not nil
  def self.wind_turbine_energy_at( command )

    city = command[:city]
    year = command[:year]
    month = command[:month]
    day = command[:day]

    energy = 0.0
    time = 0.0
    avg_wind_speed_sum = 0.0

    # if both files don't exist we can't do anything
    metar_file = MetarTools.log_filename(city, year, month)
    yaml_file = MetarTools.output_filename( city, year, month)
    if not File.exist?( metar_file ) and not File.exist?( yaml_file )
      return :file_not_exist
    else

      # if yaml doens't exist we can create it or if it is not mature
      command_process = {
        :city => city,
        :year => year,
        :month => month
      }
      if not File.exist?( yaml_file ) or is_mature?( command_process, true ) == false
        process( command_process )
      end

      # load processed data
      data = YAML::load_file( yaml_file )
      begin
        data = data.select{ |d| d.class.to_s == "Hash" and not d[:time_unix].nil?}
      rescue => e
        puts e.inspect
        exit!
      end
      data.sort!{ |d,e| d[:time_unix] <=> e[:time_unix] }

      # if day is set calculate only for that day
      if not day.nil?

        time_from = Time.mktime(year, month, day, 0, 0, 0)
        time_to = Time.mktime(year, month, day, 23, 59, 59)

        data.select!{ |d| d[:time_unix] >= time_from and d[:time_unix] <= time_to }
      end

      # calculating
      prev_time = nil
      data.each do |d|

        # jeśli nie jest puste to można robić różnice
        if not prev_time.nil?

          # one time range
          t = (d[:time_unix] - prev_time)

          # energy Ws
          energy += current_for_wind_speed( d[:wind].to_f ) * t

          # sum for time
          time += t

          # sum for avg wind speed
          avg_wind_speed_sum += ( d[:wind].to_f * t )

        end

        prev_time = d[:time_unix]

      end

      h_data = Hash.new

      # total seconds in month
      h_data[:total_month_time] = Time.days_in_month( month.to_i, year.to_i ) * 24 * 3600

      # avg potential power per second
      h_data[:avg_power] = energy.to_f / time.to_f

      # potential energy for full month
      h_data[:full_month_potential_energy] = h_data[:avg_power] * h_data[:total_month_time]

      # potential energy for full month
      h_data[:logged_month_potential_energy] = energy

      # logged time
      h_data[:logged_month_time] = time

      h_data[:avg_wind_speed] = avg_wind_speed_sum / time


      return {
        :city => city,
        :year => year,
        :month => month,
        :energy => h_data
      }
      
    end
  end

  private

  # Return watts for wind speed in km/h for 1kW wind turbine
  def self.current_for_wind_speed( wind_kmh )

    wind_ms = wind_kmh / 3.6

    if wind_ms >= 3.0 and not wind_ms > 7.0
      return (wind_ms - 3.0) * 700.0 / 4.0
    elsif wind_ms >= 7.0 and not wind_ms > 11.0
      return (wind_ms - 7.0) * 500.0 / 4.0 + 700.0
    elsif wind_ms >= 11.0 and not wind_ms > 15.0
      return (wind_ms - 11.0) * 200.0 / 4.0 + 1200.0
    elsif wind_ms >= 15.0 and not wind_ms > 23.0
      return (wind_ms - 15.0) * (-300.0) / 8.0 + 1400.0
    else
      return 0.0
    end
  end
  
end
