require 'singleton'

# Backup storage

module HomeIoServer
  class WeatherBuffer
    include Singleton

    def initialize
      @logger = HomeIoLogger.l('weather_buffer')
      @buffer_fetched = Hash.new

      clear_storage_buffer
    end

    def clear_storage_buffer
      @buffer_ar_storage = Array.new
      @buffer_txt_storage = Hash.new
    end

    def fetch_city(_city)
      providers = providers_for_city_for_current_fetch(_city)
      providers.each do |provider|
        p = provider.new(_city)
        begin
          p.fetch
        rescue => ex
          @logger.error("Fetch fail, provider #{provider}, city #{_city.inspect}")
          @logger.error("#{ex.backtrace}: #{ex.message} (#{ex.class})")
        end
        after_fetch(p.weathers)
      end
    end

    def after_fetch(wd_array)
      wd_array.each do |wd|
        if wd.is_metar?
          check_and_add_metar(wd)
        else
          check_and_add_weather(wd)
        end
      end
    end

    # Add only if there is nothing with similar metar string and time_from
    def check_and_add_metar(wd)
      if 0 == @buffer_fetched[wd.city_hash].select {
        |wd_archived| wd_archived.metar_string == wd.metar_string and
          wd_archived.time_from == wd.time_from and
          wd_archived.time_to == wd.time_to and
          wd_archived.is_metar?
      }.size

        @buffer_fetched[wd.city_hash] << wd
        add_to_storage_buffer(wd)
      end
    end

    # Add or overwrite if there is something with identical city, provider, time_from
    def check_and_add_weather(wd)
      @buffer_fetched[wd.city_hash] = @buffer_fetched[wd.city_hash].delete_if {
        |wd_archived| wd_archived.city_hash == wd.city_hash and
          wd_archived.provider == wd.provider and
          wd_archived.time_from == wd.time_from and
          wd_archived.time_to == wd.time_to
      }

      @buffer_fetched[wd.city_hash] << wd
      add_to_storage_buffer(wd)
    end

    # Add to both AR and txt storage
    def add_to_storage_buffer(wd)
      add_to_ar_storage_buffer(wd)
      if wd.is_metar?
        add_metar_to_txt_storage_buffer(wd)
      else
        add_weather_to_txt_storage_buffer(wd)
      end
    end

    # Add to AR storage
    def add_to_ar_storage_buffer(wd)
      @buffer_ar_storage << wd
    end

    def add_metar_to_txt_storage_buffer(wd)
      fn = "data/metar/#{wd.metar_code}/#{Time.now.year}/metar_#{wd.metar_code}_#{Time.now.year}_#{Time.now.month}.log"
      @buffer_txt_storage[fn] ||= Array.new
      @buffer_txt_storage[fn] << wd.metar_string
    end

    def add_weather_to_txt_storage_buffer(wd)
      fn = "data/weather/#{wd.provider}.txt"
      @buffer_txt_storage[fn] ||= Array.new
      @buffer_txt_storage[fn] << wd.to_text
    end

    # Store it now!
    def flush_storage_buffer
      # TXT
      @buffer_txt_storage.keys.each do |fn|
        path = File.dirname(fn)
        FileUtils.mkdir_p path unless File.exists?(path)

        f = File.new(fn, 'a')
        @buffer_txt_storage[fn].each do |s|
          f.puts s
        end
        f.close

        @logger.debug("Stored in file #{fn} #{@buffer_txt_storage[fn].size} records")
      end

      # AR
      @buffer_ar_storage.each do |wd|
        ar = wd.to_ar
        @logger.warn("Error while storing weather: #{ar.errors.inspect}, #{ar.inspect}") unless ar.save
      end
      @logger.debug "Stored #{@buffer_ar_storage.size} records"

      # clear buffer
      clear_storage_buffer
      
      # clean fetch buffer
      clean_after_two_days
    end

    def clean_after_two_days
      @buffer_fetched.keys.each do |k|
        @buffer_fetched[k] = @buffer_fetched[k].delete_if{|wd| (Time.now - wd.time_created) > 2*24*3600}
      end
    end

    # Which provider should be used now
    # Based on provider weather refresh interval
    def providers_for_city_for_current_fetch(_city)
      return WeatherFetcher::SchedulerHelper.recommended_providers(buffer_for_city(_city))
    end

    def buffer_for_city(_city)
      @buffer_fetched[_city] ||= Array.new
      return @buffer_fetched[_city]
    end

  end
end