require 'singleton'
require 'lib/config_loader'

require 'lib/weather_ripper/weather_onet_pl'
require 'lib/weather_ripper/weather_wp_pl'

# Fetch weather information from various web pages (mainly polish ones)
class WeatherRipper
  include Singleton
  
  def initialize
    @@config = ConfigLoader.instance.config( self.class )

    @onet_pl = WeatherOnetPl.new
    @onet_pl.check_all

    @wp_pl = WeatherWpPl.new
    @wp_pl.check_all
  end
end
