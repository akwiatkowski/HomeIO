require 'singleton'

# better way to load all files from dir
Dir["./lib/metar/metar_ripper/*.rb"].each {|file| require file }


# Rips raw metar from various sites

class MetarRipper
  include Singleton

  # some providers has slow webpages, turing them off will reduce time cost
  USE_ALSO_SLOW_PROVIDERS = false

  attr_reader :klasses
  
  def initialize
    @klasses = [
      MetarRipperNoaa, # superfast <0.5s
      MetarRipperAviationWeather, # fast 0.4-1s
      MetarRipperWunderground, # not fast 1-2s
    ]

    if USE_ALSO_SLOW_PROVIDERS
      @klasses << MetarRipperAllMetSat # slowest, 4s
    end

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
