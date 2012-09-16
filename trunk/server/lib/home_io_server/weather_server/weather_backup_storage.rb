require 'singleton'

# Backup storage

module HomeIoServer
  class WeatherBackupStorage
    include Singleton

    def initialize
      ['data', 'data/metar', 'data/weather'].each do |p|
        Dir.mkdir(p) unless File.exists?(p)
      end

      @metars = Hash.new
    end

    def store(wd_array)
      wd_array.each do |wd|
        if wd.is_metar?
          store_metar(wd)
        else
          store_weather(wd)
        end
      end
    end

    def store_metar(wd)
      create_metar_path(wd.metar_code) # TODO some optimization in future
      @metars[wd.metar_code] ||= Array.new

      if ([wd.metar_string] & @metars[wd.metar_code]).size == 0
        f = File.new("data/metar/#{wd.metar_code}/#{Time.now.year}/metar_#{wd.metar_code}_#{Time.now.year}_#{Time.now.month}.log", "a")
        f.puts wd.metar_string
        f.close

        @metars[wd.metar_code] << wd.metar_string
      end

    end

    def store_weather(wd)
      f = File.new("data/weather/#{wd.provider}.txt", "a")
      f.puts wd.to_text
      f.close
    end

    def create_metar_path(metar_code)
      ["data/metar/#{metar_code}", "data/metar/#{metar_code}/#{Time.now.year}"].each do |p|
        Dir.mkdir(p) unless File.exists?(p)
      end
    end

  end
end