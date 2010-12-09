require 'singleton'

# better way to load all files from dir
Dir["./lib/metar/metar_ripper/*.rb"].each {|file| require file }


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

    # return uniq and not blank
    codes = codes.select{|c| not '' == c.to_s.strip}.uniq
    return codes
  end

  

end
