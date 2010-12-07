require './lib/metar_ripper/metar_ripper_abstract.rb'

class MetarRipperAllMetSat < MetarRipperAbstract

  def url( city)
    u = "http://pl.allmetsat.com/metar-taf/polska.php?icao=#{city.upcase}"
    return u
  end

  def process( body )
    reg = /<b>METAR:<\/b>([^<]*)<br>/
    body = body.scan(reg).first.first
    body.gsub!(/\n/,' ')
    body.gsub!(/\t/,' ')
    body.gsub!(/\s{2,}/,' ')
    #body = "\n#{body.strip}\n"
    return body
  end

end
