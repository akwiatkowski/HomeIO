require './lib/metar/metar_ripper/metar_ripper_abstract.rb'

class MetarRipperWunderground < MetarRipperAbstract

  def url( city)
    u = "http://www.wunderground.com/Aviation/index.html?query=#{city.upcase}"
    return u
  end

  def process( body )
    reg = /<div class=\"textReport\">\s*METAR\s*([^<]*)<\/div>/
    body = body.scan(reg).first.first
    body.gsub!(/\n/,' ')
    body.gsub!(/\t/,' ')
    body.gsub!(/\s{2,}/,' ')
    return body.strip
  end

end
