require 'lib/metar_tools'
#require 'lib/metar_logger'
require 'lib/metar_processor'

Thread.abort_on_exception = true
config = MetarTools.load_config

MetarProcessor.prepare

cities = config[:cities]
cities.each do |c|
  city = c[:code]
  
  # process only current month
  MetarProcessor.process({:city => city, :year => Time.now.year, :month => Time.now.month })
  
  # if yesterday was previous month
  if (Time.now.month != (Time.now - 24*3600).month )
    prev_month = Time.now.month - 1
    year = Time.now.year
    if prev_month == 0
      prev_month = 12
      year -= 1
    end

    MetarProcessor.process({:city => city, :year => year, :month => prev_month })

  end

end


