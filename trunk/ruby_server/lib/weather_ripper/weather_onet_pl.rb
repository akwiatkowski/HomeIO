require './lib/weather_ripper/weather_base.rb'

class WeatherOnetPl < WeatherBase

  def self.provider_name
    "Onet.pl"
  end

  def process( body_raw )

    body = body_raw.downcase

    #times = time_now = body.scan(/<span class=\"ar2 gold\">([0-9.]+)<\/span>/)
    times = body.scan(/<span class=\"ar2 gold\">(\d{1,2})\.(\d{1,2})\.(\d{4})<\/span>/)
    times = times.collect{|t|
      t_from = Time.mktime(
        t[2].to_i,
        t[1].to_i,
        t[0].to_i,
        0, 0, 0, 0)

      { :time_from => t_from, :time_to => t_from + 24*3600 }
    }
    # puts times.inspect

    temperatures = body.scan(/<span title=\"temperatura w dzie.\">([-.0-9]+)<\/span>\s*<span title=\"temperatura w nocy\"[^>]*>([-.0-9]+)<\/span>/)
    temperatures = temperatures.collect{|t|
      {:temperature_night => t[1].to_f, :temperature_day => t[0].to_f, :temperature => (t[0].to_f + t[1].to_f)/2.0}
    }
    # puts temperatures.inspect

    #pressures = body.scan(/>(\d+)\s*hpa</)
    pressures = body.scan(/(\d+)\s*hpa/)
    pressures = pressures.collect{|t| t[0].to_i}
    # puts pressures.inspect

    # wind speed in m/s
    winds = body.scan(/(\d+)\s*km\/h/)
    winds = winds.collect{|t| t[0].to_f / 3.6}
    # puts winds.inspect

    snows = body.scan(/nieg:<\/td><td class="[^"]*">([0-9.]*)\s*mm</)
    snows = snows.collect{|t| t[0].to_f}
    # puts snows.inspect

    rains = body.scan(/eszcz:<\/td><td class=\"[^"]*\">\s*([0-9.]*)\s*mm</)
    rains = rains.collect{|t| t[0].to_f}
    # puts rains.inspect

    data = Array.new
    ( 0...(times.size) ).each do |i|
      h = {
        :time_created => Time.now,
        :time_from => times[i][:time_from],
        :time_to => times[i][:time_to],
        :temperature => temperatures[i][:temperature],
        :pressure => pressures[i],
        :wind_kmh => winds[i] * 3.6,
        :wind => winds[i],
        :snow => snows[i],
        :rain => rains[i],
        :provider => self.class.provider_name,
        :weather_provider_id => id
      }
      data << h
    end

    # puts data.inspect
    # exit!

    return data
  end
end
