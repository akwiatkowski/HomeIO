require './lib/metar/metar_ripper/metar_ripper_abstract.rb'

class MetarRipperNoaa < MetarRipperAbstract

  # remove time information, which is not part of metar
  REMOVE_TIME_BEFORE_METAR = true


  def url( city)
    # u = "http://weather.noaa.gov/pub/data/observations/metar/stations/#{city.upcase}.TXT"
    # u = "http://weather.noaa.gov/pub/data/observations/metar/decoded/#{city.upcase}.TXT"
    u = "http://weather.noaa.gov/pub/data/observations/metar/stations/#{city.upcase}.TXT"
    return u
  end

  def process( body )

    if REMOVE_TIME_BEFORE_METAR
      # remove 2010/12/09 18:35\n
      body.gsub!(/\d{4}\/\d{1,2}\/\d{1,2} \d{1,2}\:\d{1,2}\s*/,' ')
    end

    body.gsub!(/\n/,' ')
    body.gsub!(/\t/,' ')
    body.gsub!(/\s{2,}/,' ')
    return body.strip
  end

end
