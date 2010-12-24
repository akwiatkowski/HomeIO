require 'lib/metar_tools'
#require 'lib/metar_logger'
require 'lib/metar_processor'

Thread.abort_on_exception = true
config = MetarTools.load_config

MetarProcessor.prepare

puts "year"
year = gets.to_i
puts "month"
month = gets.to_i

cities = config[:cities]
cities.each do |c|
  city = c[:code]
  
  # process only current month
  MetarProcessor.process({:city => city, :year => year, :month => month })

end


