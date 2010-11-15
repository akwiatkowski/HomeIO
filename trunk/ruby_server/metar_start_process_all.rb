require 'lib/metar_tools'
#require 'lib/metar_logger'
require 'lib/metar_processor'

Thread.abort_on_exception = true
config = MetarTools.load_config

MetarProcessor.prepare

cities = config[:cities]
cities.each do |c|
  city = c[:code]
  MetarProcessor.process_city( city )
end


