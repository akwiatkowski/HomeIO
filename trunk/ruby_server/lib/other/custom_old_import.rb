#!/usr/bin/ruby1.9.1
#encoding: utf-8

# require './lib/metar_logger.rb'
require 'iconv'
require './lib/utils/config_loader.rb'
require './lib/metar/metar_constants.rb'
require './lib/storage/storage.rb'

# Import file created using metar data in other, non-standard, format

class CustomOldImport
  def initialize( file, city )
    @storage = StorageActiveRecord.instance

    @city = City.find_by_name( city )
    @iconv_from_latin2 = Iconv.new('UTF-8','ISO-8859-2')
    # puts @city.inspect

    f = File.open( file, "r")
    f.each do |line|
      # parse do AR object
      obj = parse_old_format_csv( line, @city.id )
      @storage.add_ar_object_to_pool( obj ) unless obj.nil?
    end
    f.close
  end

  private

  # Parse line and create WeatherMetarArchive object
  def parse_old_format_csv( line, city_id )
    # 1107682200;2005;2;6;niedziela;10;30;-6;18;ESE;1036
    #
    # 1. 1107682200
    # 2. -6
    # 3. 18
    # 4. 1036

    line = @iconv_from_latin2.iconv( line )
    
    if line =~ /(\d+);\d+;\d+;\d+;[^;]+;\d+;\d+;([^;]+);([^;]+);[^;]+;([^;]+)/
      time_from = Time.at( $1.to_i )

      wma = WeatherMetarArchive.new
      wma.time_from = time_from
      wma.time_to = time_from + 30*60
      wma.temperature = $2.to_f
      wma.wind = $3.to_f / 3.6 # wind in m/s
      wma.pressure = $4.to_i
      wma.city_id = city_id
      wma.raw = "N/A"
      # puts wma.inspect

      return wma
    end
    return nil
  end

end


CustomOldImport.new('./config/input/other/EPPO.csv', 'Poznań')