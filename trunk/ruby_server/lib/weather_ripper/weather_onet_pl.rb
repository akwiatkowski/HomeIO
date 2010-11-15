require 'lib/weather_ripper/weather_base'

class WeatherOnetPl < WeatherBase
  def initialize
    @config = ConfigLoader.instance.config( self.class )
    @defs = @config[:defs]
  end

  def process( body_raw )

    body = body_raw.downcase

    temperatures = body.scan(/<b\s*title=\"temperatura\">([^<]*)<\/b>/)
    pressures = body.scan(/\>(\d*)\s*hpa\s*\</)
    winds = body.scan(/(\d*)\s*km\/h/)
    snows = body.scan(/nieg:<\/td><td class=\"[^"]*\">\s*([0-9.]*)\s*mm</)
    rains = body.scan(/eszcz:<\/td><td class=\"[^"]*\">\s*([0-9.]*)\s*mm</)

    # time now
    time_now = body.scan(/<span class="ar2b gold">teraz <\/span><span class="ar2 gold">(\d*)-(\d*)<\/span>/)
    # time soon
    time_soon = body.scan(/<span class="ar2b gold">wkr.tce <\/span><span class="ar2 gold">(\d*)-(\d*)<\/span>/)

    unix_time_today = Time.mktime(
      Time.now.year,
      Time.now.month,
      Time.now.day,
      0, 0, 0, 0)

    unix_time_now_from = unix_time_today + 3600 * time_now[0][0].to_i
    unix_time_now_to = unix_time_today + 3600 * time_now[0][1].to_i
    if time_now[0][1].to_i < time_now[0][0].to_i
      # next day
      unix_time_now_to += 24 * 3600
    end

    unix_time_soon_from = unix_time_today + 3600 * time_soon[0][0].to_i
    unix_time_soon_to = unix_time_today + 3600 * time_soon[0][1].to_i
    if time_soon[0][1].to_i < time_soon[0][0].to_i
      # next day
      unix_time_soon_to += 24 * 3600
    end
    if time_now[0][0].to_i > time_soon[0][0].to_i
      # time soon is whole new day
      unix_time_soon_from += 24 * 3600
      unix_time_soon_to += 24 * 3600
    end

    #puts time_now.inspect, time_soon.inspect
    #puts unix_time_now_from, unix_time_now_to

    #    doc = Hpricot.parse(body)
    #    i = 0
    #    (doc/:td/:b).each do |t|
    #      if t.attributes[:title] == "temperatura"
    #        data[i][:temperature] = t.to_plain_text.to_f
    #      end
    #    end

    data = [
      {
        :time_created => Time.now,
        :time_from => unix_time_now_from,
        :time_to => unix_time_now_to,
        :temperature => temperatures[0][0].to_f,
        :pressure => pressures[0][0].to_f,
        :wind_kmh => winds[0][0].to_f,
        :wind => winds[0][0].to_f / 3.6,
        :snow => snows[0][0].to_f,
        :rain => rains[0][0].to_f,
        :provider => 'Onet.pl'
      },
      {
        :time_created => Time.now,
        :time_from => unix_time_soon_from,
        :time_to => unix_time_soon_to,
        :temperature => temperatures[1][0].to_f,
        :pressure => pressures[1][0].to_f,
        :wind_kmh => winds[1][0].to_f,
        :wind => winds[1][0].to_f / 3.6,
        :snow => snows[1][0].to_f,
        :rain => rains[1][0].to_f,
        :provider => 'Onet.pl'
      }
    ]

    #puts "Onet.pl #{unix_time_now_from} - #{unix_time_now_to}, #{unix_time_soon_from} - #{unix_time_soon_to}"
    #puts data.inspect

    return data
  end
end
