require './lib/weather_ripper/weather_base.rb'

class WeatherWpPl < WeatherBase
  def initialize
    @config = ConfigLoader.instance.config( self.class )
    @defs = @config[:defs]
  end

  def process( body_raw )

    body = body_raw.downcase

    hours = body.scan(/>(\d+)-(\d+)/)
    #puts hours.inspect
    temperatures = body.scan(/temperatura: <strong>(\d*)[^<]*<\/strong>/)
    #puts temperatures.inspect
    winds = body.scan(/<strong>(\d*\.?\d*)\s*km\/h<\/strong>/)
    winds.slice!(0,5)
    #puts winds.inspect

    #puts hours.size
    #puts temperatures.size
    #puts winds.size

    #    data = Array.new
    #    (0...(hours.size)).each do |i|
    #      data << {
    #        :hours => hours[i],
    #        :temperatures => temperatures[i],
    #        :wind => winds[i],
    #      }
    #
    #      puts "h #{hours[i]}\ntemp #{temperatures[i]}\nwind #{winds[i]}\n\n"
    #    end

    #puts data.inspect

    unix_time_today = Time.mktime(
      Time.now.year,
      Time.now.month,
      Time.now.day,
      0, 0, 0, 0)

    unix_time_now_from = unix_time_today + 3600 * hours[0][0].to_i
    unix_time_now_to = unix_time_today + 3600 * hours[0][1].to_i
    if hours[0][1].to_i < hours[0][0].to_i
      # next day
      unix_time_now_to += 24 * 3600
    end

    unix_time_soon_from = unix_time_today + 3600 * hours[1][0].to_i
    unix_time_soon_to = unix_time_today + 3600 * hours[1][1].to_i
    if hours[1][1].to_i < hours[1][0].to_i
      # next day
      unix_time_soon_to += 24 * 3600
    end
    if hours[1][0].to_i > hours[1][0].to_i
      # time soon is whole new day
      unix_time_soon_from += 24 * 3600
      unix_time_soon_to += 24 * 3600
    end

    # if 1 data is for next day morning
    if hours[0][1].to_i < Time.now.hour
      unix_time_now_to += 24 * 3600
      unix_time_now_from += 24 * 3600

      unix_time_soon_to += 24 * 3600
      unix_time_soon_from += 24 * 3600
    end


    data = [
      {
        :time_created => Time.now,
        :time_from => unix_time_now_from,
        :time_to => unix_time_now_to,
        :temperature => temperatures[0][0].to_f,
        #:pressure => nil,
        :wind_kmh => winds[0][0].to_f,
        :wind => winds[0][0].to_f / 3.6,
        #:snow => snows[0][0].to_f,
        #:rain => rains[0][0].to_f,
        :provider => 'Wp.pl'
      },
      {
        :time_created => Time.now,
        :time_from => unix_time_soon_from,
        :time_to => unix_time_soon_to,
        :temperature => temperatures[1][0].to_f,
        #:pressure => pressures[1][0].to_f,
        :wind_kmh => winds[1][0].to_f,
        :wind => winds[1][0].to_f / 3.6,
        #:snow => snows[1][0].to_f,
        #:rain => rains[1][0].to_f,
        :provider => 'Wp.pl'
      }
    ]

    #puts data.inspect
    #exit!

    return data
  end
end
