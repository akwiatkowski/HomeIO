# Jeden kod METAR

class MetarCode
  attr_reader :output, :metar_string, :metar_splits, :year, :month

  # maksymalna widoczność jaką zapisujemy
  MAX_VISIBLITY = 10_000

  # Czyszczenie danych przed przetwarzaniem
  def clear
    @output = Hash.new
    @metar_string = ""
    @year = nil
    @month = nil
  end

  # Zwraca utworzony obiekt typu MetarCode przetwarzając kod METAR
  def process( string, year, month )

    # usuń wcześniejsze dane
    clear
    @metar_string = string
    @metar_splits = @metar_string.split(' ')
    @year = year
    @month = month

    # przetwarzanie
    decode

    return @output

  end

  # Accesor
  def raw
    return @metar_string
  end

  # If metar string was valid and was processed ok
  def valid?
    return true if not @output[:temperature].nil? and not @output[:wind].nil? and not @output[:time].nil?
    return false
  end

  # Convert decoded METAR to hash object prepared to store in DB
  def decoded_to_weather_db_store
    return {
      :time_created => Time.now,
      :time_from => @output[:time].to_i,
      :time_to => (@output[:time].to_i + 30*60), # TODO przenieść do stałych
      :temperature => @output[:temperature],
      :pressure => @output[:pressure],
      :wind_kmh => @output[:wind],
      :wind => @output[:wind].nil? ? nil : @output[:wind].to_f / 3.6,
      :snow => nil,
      :rain => nil,
      :provider => 'METAR',
      :raw => @metar_string
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
  end

  # Miasto
  def decode_city( s )
    if s =~ /^([A-Z]{4})$/ and not s == 'AUTO'
      @output[:city] = $1
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

      @output[:wind] = wind
      @output[:wind_max] = wind_max
      @output[:wind_direction] = $1.to_i
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
    @output[:clouds] = 0
    if s =~ /^(SKC|FEW|SCT|BKN|OVC|NSC)(\d{3}?)$/
      cl = case $1
      when "SKC" then 0
      when "FEW" then 1.5
      when "SKC" then 3.5
      when "BKN" then 6
      when "OVC" then 8
      when "NSC" then 0.5
      else 0
      end
        
      @output[:clouds] = (cl * 100.0 / 8.0).round
      @output[:clouds_bottom] = $2.to_i * 30
    end
  end

  # CAVOK
  def check_cavok( s )
    #CAVOK
    if s =~ /^(CAVOK)$/
      @output[:clouds] = 0
      @output[:clouds_bottom] = nil
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

		if s =~ /(VC|\-|\+|\b)(MI|PR|BC|DR|BL|SH|TS|FZ|)(DZ|RA|SN|SG|IC|PE|GR|GS|UP|)(BR|FG|FU|VA|DU|SA|HZ|PY|)(PO|SQ|FC|SS|)/
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

      if @output[:specials].nil?
        @output[:specials] = Array.new
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

  
  
  



end
