require './lib/metar/metar_constants.rb'
require './lib/utils/config_loader.rb'
require './lib/storage/storage.rb'
require './lib/storage/storage_interface.rb'
require './lib/utils/adv_log.rb'

# Metar code model

class MetarCode
  include StorageInterface
  
  attr_reader :output, :metar_string, :metar_splits, :year, :month, :city, :city_id

  # Type from where come this metar, ex: :archived, :fresh
  attr_reader :type

  # maksymalna widoczność jaką zapisujemy
  MAX_VISIBLITY = 10_000

  # once metar is normally for 30 minutes
  TIME_INTERVAL = 30*60

  def initialize
    clear
  end

  # Czyszczenie danych przed przetwarzaniem
  def clear
    @output = Hash.new
    @metar_string = ""
    @year = nil
    @month = nil

    @output[:time] = nil
    @output[:specials] = Array.new
    @output[:clouds] = Array.new

    @city_hash = Hash.new
    @city = @city_hash[:code]
  end

  # Process non-fresh metar string
  def process_archived( string, year, month )
    process( string, year, month, :archived )
  end

  # Zwraca utworzony obiekt typu MetarCode przetwarzając kod METAR
  def process( string, year, month, type )

    # type:
    # :archived => stored raw in text files, can only update DB (not implememted yet), but not raw logs
    # :fresh => just downloaded, can be store everywhere
    @type = type

    # usuń wcześniejsze dane
    clear
    begin
      @metar_string = string.to_s.gsub(/\s/,' ').strip
      @metar_splits = @metar_string.split(' ')
      @year = year
      @month = month

      # przetwarzanie
      decode
    rescue
      AdvLog.instance.logger( self ).error("Error when processing '#{@metar_string}'")
    end

    return @output

  end

  # Process metar string in newly created MetarCode instance
  def self.process( string, year, month, type )
    mc = self.new
    mc.process( string, year, month, type )
    return mc
  end

  # Process non-fresh metar string
  def self.process_archived( string, year, month )
    self.process( string, year, month, :archived )
  end

  # Process array of metar strings
  def self.process_array( array, year, month, type )
    oa = Array.new
    array.each do |a|
      puts a
      mc = process( a, year, month, type )
      oa << mc
    end
    return oa
  end

  # Accesor
  def raw
    return @metar_string
  end

  # If metar string id valid, processed ok with basic data, and time was correct
  def valid?
    # metar doesn't need to have temp., wind
    if not @output[:temperature].nil? and
        not @output[:wind].nil? and
        not @output[:time].nil? and
        @output[:time] <= Time.now and
        @output[:time].year == self.year.to_i and
        @output[:time].month == self.month.to_i
      return true
    end

    return false
  end

  # If metar string was decoded and it contains basic data
  def valid_basic_data?
    if not @output[:temperature].nil? and
        not @output[:wind].nil? and
        not @output[:time].nil?
      return true
    end
    return false
  end

  # Store
  def store
    # send self to Storage
    Storage.instance.store( self ) if valid?
  end

  # Convert decoded METAR to hash object prepared to store in DB
  def to_db_data
    return {
      :data => {
        :created_at => Time.now.to_i,
        :time_from => @output[:time].to_i,
        :time_to => (@output[:time].to_i + 30*60), # TODO przenieść do stałych
        :temperature => @output[:temperature],
        :pressure => @output[:pressure],
        :wind_kmh => @output[:wind],
        :wind => @output[:wind].nil? ? nil : @output[:wind].to_f / 3.6,
        :snow_metar => @output[:snow_metar],
        :rain_metar => @output[:rain_metar],
        :provider => "'METAR'",
        # escaping slashes
        #:raw => "'#{@metar_string.gsub(/\'/,"\\\\"+'\'')}'",
        :raw => "'#{@metar_string}'",
        :city_id => @city_id,
        :city => "'#{@city}'",
        :city_hash => @city_hash
      },
      :columns => [
        :created_at, :time_from, :time_to, :temperature, :pressure, :wind,
        :snow_metar, :rain_metar, :city_id, :raw
      ]
    }
  end

  private

  # Przetworzenie kodu po kolei
  def decode
    @metar_splits.each do |s|
      decode_city( s )

      decode_time( s )
      decode_wind( s )
      decode_wind_variable( s )
      decode_temperature( s )
      decode_pressure( s )
      decode_visiblity( s )
      decode_clouds( s )
      

      decode_specials( s )

      check_cavok( s )

      decode_humidity
    end

    # one time last processes
    fetch_additional_city_info
    calculate_cloud
    # calculate in metar units
    calculate_rain_and_snow


    # if metar is invalid store it in log to check if decoder has error
    if true == ConfigLoader.instance.config( self.class.to_s )[:store_decoder_errors]
      unless valid_basic_data?
        AdvLog.instance.logger( self ).error("Cant decode metar: '#{self.raw}', city '#{self.city}'")
      end
    end

  end

  # Miasto
  def decode_city( s )
    # only first
    return if not @output[:city].nil?

    if s =~ /^([A-Z]{4})$/ and not s == 'AUTO' and not s == 'GRID'
      @output[:city] = $1
    end
  end

  # Store all additional information from metar.yml
  def fetch_additional_city_info
    # uses singleton to store all configs
    # load 'metar' config
    # search for current city
    @city_hash = ConfigLoader.instance.config( MetarConstants::CONFIG_TYPE )[:cities].select{|c| c[:code] == @output[:city]}.first
    if @city_hash.nil?
      @city_id = nil
      @city = nil
    else
      @city_id = @city_hash[:id]
      @city = @city_hash[:code]
    end
  end

  # Czas
  def decode_time( s )
    begin
      if s =~ /(\d{2})(\d{2})(\d{2})Z/
        @output[:time] = Time.utc(@year, @month, $1.to_i, $2.to_i, $3.to_i, 0, 0)
        @output[:time_unix] = @output[:time].to_i
      end
    rescue
    end
  end

  # Wiatr
  def decode_wind( s )
    #if s =~ /(\d{3})(\d{2})(KT|MPS|KMH)/ # bez porywistości
    if s =~ /(\d{3})(\d{2})G?(\d{2})?(KT|MPS|KMH)/
      # podzial na rozne jednostki predkosci

      wind = case $4
      when "KT" then $2.to_f * 1.85
      when "MPS" then $2.to_f * 1.6
      when "KMH" then $2.to_f
      else nil
      end

      wind_max = case $4
      when "KT" then $3.to_f * 1.85
      when "MPS" then $3.to_f * 1.6
      when "KMH" then $3.to_f
      else nil
      end

      # wind_max is not less than normal wind
      if wind_max < wind or wind_max.nil?
        wind_max = wind
      end

      # additional wind data
      if not @output[:wind].nil?
        if @output[:wind_additionals].nil?
          @output[:wind_additionals] = Array.new
        end

        @output[:wind_additionals] << {
          :wind => wind,
          :wind_max => wind_max,
          :wind_direction => $1.to_i
        }
      else
        @output[:wind] = wind
        @output[:wind_mps] = wind / 3.6
        @output[:wind_max] = wind_max
        @output[:wind_direction] = $1.to_i
      end
    end

    # variable/unknown direction
    if s =~ /VRB(\d{2})(KT|MPS|KMH)/
      wind = case $2
      when "KT" then $1.to_f * 1.85
      when "MPS" then $1.to_f * 1.6
      when "KMH" then $1.to_f
      else nil
      end

      # additional wind data
      if not @output[:wind].nil?
        if @output[:wind_additionals].nil?
          @output[:wind_additionals] = Array.new
        end

        @output[:wind_additionals] << {
          :wind => wind,
          :wind_max => wind_max,
          :wind_direction => $1.to_i
        }
      else
        @output[:wind] = wind
        @output[:wind_mps] = wind / 3.6
        @output[:wind_max] = wind_max
        @output[:wind_direction] = $1.to_i
      end
      
    end


  end

  # Zmienny kierunek wiatru
  def decode_wind_variable( s )
    if s =~ /(\d{3})V(\d{3})/
      @output[:wind_variable_direction_from] = $1.to_i
      @output[:wind_variable_direction_to] = $2.to_i
    end

  end

  # Temperatura
  def decode_temperature( s )
    if s =~ /^(M?)(\d{2})\/(M?)(\d{2})$/

      if $1 == "M"
        @output[:temperature] = -1.0 * $2.to_f
      else
        @output[:temperature] = $2.to_f
      end

      if $3 == "M"
        @output[:temperature_dew] = -1.0 * $4.to_f
      else
        @output[:temperature_dew] = $4.to_f
      end

      return
    end

    if s =~ /^(M?)(\d{2})\/$/

      if $1 == "M"
        @output[:temperature] = -1.0 * $2.to_f
      else
        @output[:temperature] = $2.to_f
      end

      return
    end

  end

  # Ciśnienie
  def decode_pressure( s )
    # Europa
    if s =~ /Q(\d{4})/
      @output[:pressure] = $1.to_i
    end
    # US
    if s =~ /A(\d{4})/
      #1013 hPa = 29.921 inNg
      @output[:pressure]=(($1.to_f)*1013.0/2992.1).round
    end
  end

  # Widoczność
  def decode_visiblity( s )
    # Europa
    if s =~ /^(\d{4})$/
      @output[:visiblity] = $1.to_i
    end

    # US
    if s =~ /^(\d{1,3})\/?(\d{0,2})SM$/

      if $2 == ""
        @output[:visiblity] = $1.to_i * 1600.0
      else
        @output[:visiblity] = $1.to_f * 1600.0 / $2.to_f
      end
    end

    #aby byla stala wartosc maksymalna
    if @output[:visiblity].to_i >= 9999
      @output[:visiblity] = MAX_VISIBLITY
    end
  end
  
  # Zachmurzenie
  def decode_clouds( s )
    #zachmurzenie

    # TODO create constants
    
    if s =~ /^(SKC|FEW|SCT|BKN|OVC|NSC)(\d{3}?)$/
      cl = case $1
      when "SKC" then 0
      when "FEW" then 1.5
      when "SCT" then 3.5
      when "BKN" then 6
      when "OVC" then 8
      when "NSC" then 0.5
      else 0
      end

      cloud = {
        :coverage => (cl * 100.0 / 8.0).round,
      }
      # optionaly cloud bottom
      unless '' == $2.to_s
        cloud[:bottom] = $2.to_i * 30
        #puts s, $2.inspect
        #exit!
      end

      @output[:clouds] << cloud
      @output[:clouds].uniq!
    end

    # obscured by clouds
    if s =~ /^(VV)(\d{3}?)$/
      @output[:clouds] << {
        :coverage => 100,
        :vertical_visiblity => $2.to_i * 30
      }

      @output[:clouds].uniq!
    end

  end

  # Calculate numeric description of clouds
  def calculate_cloud
    @output[ :cloudiness ] = 0
    @output[:clouds].each do |c|
      @output[ :cloudiness ] = c[:coverage] if @output[ :cloudiness ] < c[:coverage]
    end
  end

  # CAVOK
  def check_cavok( s )
    #CAVOK
    if s =~ /^(CAVOK)$/
      @output[:clouds] = [
        {
          :coverage => 0,
          :bottom => 0
        }
      ]
      @output[:visiblity] = MAX_VISIBLITY
    end
  end

  # Oblicza wilgotność względną
  #
  # http://github.com/brandonh/ruby-metar/blob/master/lib/metar.rb
  # http://www.faqs.org/faqs/meteorology/temp-dewpoint/
  def decode_humidity
    return if @output[:temperature_dew].nil? or @output[:temperature].nil?

    es0 = 6.11 # hPa
    t0 = 273.15 # kelvin
    td = @output[:temperature_dew] + t0 # w kelwinach
    t = @output[:temperature] + t0 # w kelwinach
    lv = 2500000 # joules/kg
    rv = 461.5 # joules*kelvin/kg
    e = es0 * Math::exp(lv/rv * (1.0/t0 - 1.0/td))
    es = es0 * Math::exp(lv/rv * (1.0/t0 - 1.0/t))
    rh = 100 * e/es
    @output[:humidity] = rh
  end

  # Zjawiska dodatkowe
  def decode_specials( s )

		if s =~ /^(VC|\-|\+|\b)(MI|PR|BC|DR|BL|SH|TS|FZ|)(DZ|RA|SN|SG|IC|PE|GR|GS|UP|)(BR|FG|FU|VA|DU|SA|HZ|PY|)(PO|SQ|FC|SS|)$/
			intensity = case $1
      when "VC" then "in the vicinity"
      when "+" then "heavy"
      when "-" then "light"
      else "moderate"
			end

			descriptor = case $2
      when "MI" then "shallow"
      when "PR" then "partial"
      when "BC" then "patches"
      when "DR" then "low drifting"
      when "BL" then "blowing"
      when "SH" then "shower"
      when "TS" then "thunderstorm"
      when "FZ" then "freezing"
      else nil
			end

			precipitation = case $3
      when "DZ" then "drizzle"
      when "RA" then "rain"
      when "SN" then "snow"
      when "SG" then "snow grains"
      when "IC" then "ice crystals"
      when "PE" then "ice pellets"
      when "GR" then "hail"
      when "GS" then "small hail/snow pellets"
      when "UP" then "unknown"
      else nil
			end

			obscuration = case $4
      when "BR" then "mist"
      when "FG" then "fog"
      when "FU" then "smoke"
      when "VA" then "volcanic ash"
      when "DU" then "dust"
      when "SA" then "sand"
      when "HZ" then "haze"
      when "PY" then "spray"
      else nil
			end

			misc = case $5
      when "PO" then "dust whirls"
      when "SQ" then "squalls"
				#when "FC " then "funnel cloud/tornado/waterspout"
      when "FC" then "funnel cloud/tornado/waterspout"
      when "SS" then "duststorm"
      else nil
			end

      # gdy nie ma sensownych danych to nic nie rób
      return if descriptor.nil? and precipitation.nil? and obscuration.nil? and misc.nil?

      @output[:specials] << {
        :intensity => intensity,
        :intensity_raw => $1,
        :descriptor => descriptor,
        :descriptor_raw => $2,
        :precipitation => precipitation,
        :precipitation_raw => $3,
        :obscuration => obscuration,
        :obscuration_raw => $4,
        :misc => misc,
        :misc_raw => $5
      }
			
		end
	end

  # Calculate precip. in metar units
  def calculate_rain_and_snow
    @snow_metar = 0
    @rain_metar = 0

    # TODO dopisać zgodnie z http://weather.cod.edu/notes/metar.html
    # sumować oceniany wielkość opadów w pseudojednostce

    @output[:specials].each do |s|
      new_rain = 0
      new_snow = 0
      coef = 1
      case s[:precipitation]
      when 'drizzle' then
        new_rain = 5

      when 'rain' then
        new_rain = 10

      when 'snow' then
        new_snow = 10
      
      when 'snow grains' then
        new_snow = 5

      when 'ice crystals' then
        new_snow = 1
        new_rain = 1

      when 'ice pellets' then
        new_snow = 2
        new_rain = 2

      when 'hail' then
        new_snow = 3
        new_rain = 3

      when 'small hail/snow pellets' then
        new_snow = 1
        new_rain = 1
      end

      case s[:intensity]
      when 'in the vicinity' then coef = 1.5
      when 'heavy' then coef = 3
      when 'light' then coef = 0.5
      when 'moderate' then coef = 1
      end

      snow = new_snow * coef
      rain = new_rain * coef

      if @snow_metar < snow
        @snow_metar = snow
      end
      if @rain_metar < rain
        @rain_metar = rain
      end

    end

    @output[:snow_metar] = @snow_metar
    @output[:rain_metar] = @rain_metar

  end

  def decode_other( s )
    if s.strip == 'AO1'
      @output[:station] = :auto_without_precipitation
    elsif s.strip == 'A02'
      @output[:station] = :auto_with_precipitation
    end

    # fully automated station
    if s.strip == 'AUTO'
      @output[:station_auto] = true
    end

  end

  def decode_runway( s )
    # NOT IMPLEMENTED

    # BIAR 130700Z 17003KT 0350 R01/0900V1500U +SN VV001 M04/M04 Q0996
    # Runway 01, touchdown zone visual range is variable from a minimum of 0900 meters until a maximum of 1500 meters, and increasing
    # http://heras-gilsanz.com/manuel/METAR-Decoder.html
  end
  
  
  



end
