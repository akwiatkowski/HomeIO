require 'lib/metar_tools'
#require 'lib/metar_logger'
require 'lib/metar_processor'

Thread.abort_on_exception = true
config = MetarTools.load_config

#MetarProcessor.prepare
#MetarProcessor.process({:city => 'NZSP', :year => 2010, :month => 11 })
#exit!      

cities = config[:cities]
#cities.each do |c|
#  city = c[:code]
#  
#  # process only current month
#  MetarProcessor.process({:city => city, :year => year, :month => month })
#
#end

# TODO ombd 2009 5

#city = 'KLAX'
#y = 2009
#(5..12).each do |m|
#	puts "#{city} #{y} #{m}"
#	MetarProcessor.process({:city => city, :year => y, :month => m })
#end
#y = 2010
#(4..10).each do |m|
#	puts "#{city} #{y} #{m}"
#	MetarProcessor.process({:city => city, :year => y, :month => m })
#end

#(1..10).each do |m|
    # MetarProcessor.process({:city => "UHHH", :year => 2010, :month => m })
#end    

(18...(cities.size)).each do |i|
#(16..16).each do |i|
    city = cities[i][:code]
#    y = 2009
#    (1..12).each do |m|
#	city = cities[i][:code]
#	puts "#{city} #{y} #{m}"
#	MetarProcessor.process({:city => city, :year => y, :month => m })
#    end
    y = 2010
	(1..10).each do |m|
	city = cities[i][:code]
	puts "#{city} #{y} #{m}"
	MetarProcessor.process({:city => city, :year => y, :month => m })
    end 

    MetarProcessor.process_city( city )
end    

#(12...17).each do |i|
# city = cities[i][:code]
# puts city
#end


