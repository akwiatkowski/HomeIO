require 'singleton'

#require './lib/metar_ripper/metar_ripper_noaa.rb'
#require './lib/metar_ripper/metar_ripper_aviation_weather.rb'

# better way to load all files from dir
Dir["./lib/metar_ripper/*.rb"].each {|file| require file }


# Rips raw metar from various sites

class MetarRipper
  include Singleton

  attr_reader :klasses
  
  def initialize
    @klasses = [
      MetarRipperNoaa,
      MetarRipperAviationWeather,
      MetarRipperWunderground,
      MetarRipperAllMetSat
    ]
  end

  def fetch( city )
    codes = Array.new
    @klasses.each do |k|
      #puts k.new.a
      codes << k.new.fetch( city )
    end
    return codes
  end

  

end
