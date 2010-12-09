require './lib/metar/metar_ripper/metar_ripper_abstract.rb'

class MetarRipperAviationWeather < MetarRipperAbstract

  def url( city)
    u = "http://aviationweather.gov/adds/metars/index.php?submit=1&station_ids=#{city.upcase}"
    return u
  end

  def process( body )
    reg = /\">([^<]*)<\/FONT>/

    body = body.scan(reg).first.first
    body.gsub!(/\n/,' ')
    body.gsub!(/\t/,' ')
    body.gsub!(/\s{2,}/,' ')
    return body.strip
  end

end
