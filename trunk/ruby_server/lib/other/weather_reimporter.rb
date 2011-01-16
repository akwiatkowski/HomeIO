#!/usr/bin/ruby1.9.1
#encoding: utf-8

# require './lib/metar_logger.rb'
require 'iconv'
require './lib/weather_ripper.rb'
require './lib/storage/storage.rb'

# Reimport stored in CSV files to ActiveRecord

class WeatherReimporter
  def initialize
    @storage = StorageActiveRecord.instance
    @wrip = WeatherRipper.instance

    @good = 0
    @bad = 0
    @t = Time.now

    # process data from all providers
    @wrip.providers.each do |p|
      load_by_provider_name( p )
    end

    # some stats
    puts "Time: #{Time.now - @t}"
    puts "Good: #{@good}"
    puts "Bad: #{@bad}"
  end

  # Process provider
  def load_by_provider_name( prov )
    name = prov.class.provider_name
    f = File.open("./data/weather/#{name}.txt",'r')
    f.each do |l|
      # puts l
      begin
        process_line( l, prov )
      rescue
        puts "RESCUE ERROR", l
      end
    end
    f.close
  end

  # Process line from file
  def process_line( line, prov )
    #return "#{data[:time_created].to_i}; '#{defin[:city].to_s}'; #{data[:provider].to_s}; #{defin[:coord][:lat]}; #{defin[:coord][:lon]};   #{data[:time_from].to_i}; #{data[:time_to].to_i}; #{data[:temperature]}; #{data[:wind]}; #{data[:pressure]}; #{data[:rain]}; #{data[:snow]}"

    data = line.scan(/([^;]+);/)
    data_snow = line.scan(/;([^;]+)/)
    # puts data.inspect
    city_name = data[1][0].gsub(/\'/,'').strip
    c = City.find_by_name( city_name )
    # puts c.inspect
    
    if c.nil?
      # city is crucial!
      puts "CITY ERROR", line
    else
      wa = WeatherArchive.new
      wa.created_at = Time.at( data[0][0].to_i )
      wa.city_id = c.id
      wa.time_from = Time.at( data[5][0].to_i )
      wa.time_to = Time.at( data[6][0].to_i )
      wa.temperature = data[7][0].to_f
      wa.wind = data[8][0].to_f
      wa.pressure = data[9][0].to_i
      wa.rain = data[10][0].to_f
      wa.snow = data_snow[0][0].to_f
      wa.weather_provider_id = prov.weather_provider_id

      #puts wa.inspect
      #puts wa.valid?
      #exit!

      if false == wa.valid?
        puts "VALID ERROR", line
        puts wa.errors.inspect
        @bad += 1
      else
        @good += 1
        @storage.add_ar_object_to_pool( wa ) unless wa.nil?
      end

      
    end
      
    
  end

end

WeatherReimporter.new