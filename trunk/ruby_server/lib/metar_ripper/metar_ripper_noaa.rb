require './lib/metar_ripper/metar_ripper_abstract.rb'

class MetarRipperNoaa < MetarRipperAbstract

  def url( city)
    # u = "http://weather.noaa.gov/pub/data/observations/metar/stations/#{city.upcase}.TXT"
    # u = "http://weather.noaa.gov/pub/data/observations/metar/decoded/#{city.upcase}.TXT"
    u = "http://weather.noaa.gov/pub/data/observations/metar/stations/#{city.upcase}.TXT"
    return u
  end

  def process( body )
    body.gsub!(/\n/,' ')
    body.gsub!(/\t/,' ')
    body.gsub!(/\s{2,}/,' ')
    return body
  end

end
