require 'singleton'
require 'fileutils'

# Backup storage

module HomeIoServer
  class WeatherBackupStorage
    include Singleton

    def initialize
      #['data', 'data/metar', 'data/weather'].each do |p|
      #  Dir.mkdir(p) unless File.exists?(p)
      #end

      @buffer = Hash.new
      @metars = Hash.new
    end

    def store(wd_array)
      wd_array.each do |wd|
        if wd.is_metar?
          add_to_metar_buffer(wd)
        else
          add_to_weather_buffer(wd)
        end
      end

      flush_buffer
    end

    #def add_to_metar_buffer(wd)
    #  create_metar_path(wd.metar_code) # TODO some optimization in future
    #  @metars[wd.metar_code] ||= Array.new
    #
    #  if ([wd.metar_string] & @metars[wd.metar_code]).size == 0
    #    f = File.new("data/metar/#{wd.metar_code}/#{Time.now.year}/metar_#{wd.metar_code}_#{Time.now.year}_#{Time.now.month}.log", "a")
    #    f.puts wd.metar_string
    #    f.close
    #
    #    @metars[wd.metar_code] << wd.metar_string
    #  end
    #
    #end

    def add_to_metar_buffer(wd)
      @metars[wd.metar_code] ||= Array.new
      if ([wd.metar_string] & @metars[wd.metar_code]).size == 0
        fn = "data/metar/#{wd.metar_code}/#{Time.now.year}/metar_#{wd.metar_code}_#{Time.now.year}_#{Time.now.month}.log"
        @buffer[fn] ||= Array.new
        @buffer[fn] << wd.metar_string
      end
    end

    def add_to_weather_buffer(wd)
      fn = "data/weather/#{wd.provider}.txt"
      @buffer[fn] ||= Array.new
      @buffer[fn] << wd.to_text
    end

    def flush_buffer
      @buffer.keys.each do |fn|
        path = File.dirname(fn)
        FileUtils.mkdir_p path unless File.exists?(path)

        f = File.new(fn, 'a')
        @buffer[fn].each do |s|
          f.puts s
        end
        f.close
        puts "#{fn} added #{@buffer[fn].size} records"
      end

      @buffer = Hash.new
    end

  end
end