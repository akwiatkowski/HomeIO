#!/usr/bin/ruby
#encoding: utf-8

# This file is part of HomeIO.
#
#    HomeIO is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    HomeIO is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.


require './lib/weather_ripper/rippers/weather_abstract.rb'

# http://pogoda.interia.pl/miasta?id=11875

class WeatherInteriaPl < WeatherAbstract

  def self.provider_name
    "Interia.pl"
  end

  # Run within begin rescue, some portals like changing schema
  def _process( body_raw )

    body = body_raw.downcase

    hours_first = body.scan(/(\d{2})\s*do\s*(\d{2})/)
    #puts hours_first.inspect
    hours_add = body.scan(/<td height=\"40\">.*(\d{2})-(\d{2}).*<\/td>/)
    #puts hours_add.inspect
    hours = hours_first + hours_add
    #puts hours.inspect

    # interia uses min/aesthes./max temperatures, aesth. used
    temperatures = body.scan(/<span\s*class=\"tex2b\"\s*style=\"font-size:\s*14px;\">(-?\d+)<\/span>/)
    # there is 'sample' temperature which should be deleted
    temperatures.delete_at( 2 ) # if temperatures[2] == 5
    #puts temperatures.inspect

    winds = body.scan(/wiatr:\D*(\d+)\D*km\/h\s*</)
    #puts winds.inspect

    rains = body.scan(/deszcz:\D*(\d+\.?\d*)\D*mm\s*</)
    #puts rains.inspect

    snows = body.scan(/nieg:\D*(\d+\.?\d*)\D*mm\s*</)
    #puts snows.inspect

    pressures = body.scan(/<b>(\d{3,4})<\/b>.*hpa/)
    #puts pressures.inspect

    # TODO fix it better!
    #puts rains.inspect
    #puts snows.inspect
    if snows.nil? or snows.size < 2
      snows = [[nil], [nil], [nil]]
    end
    if rains.nil? or rains.size < 2
      rains = [[nil], [nil], [nil]]
    end


    #puts hours.size
    #puts temperatures.size
    #puts winds.size

    #puts body
    #exit!

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
    
    # TODO zrób auto testy dla innych typów
    # TODO i dodaj inkrementacje dnia po
    # if 1 data is for next day morning
    if unix_time_now_to > unix_time_soon_to
      unix_time_soon_to += 24 * 3600
      unix_time_soon_from += 24 * 3600
    end

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
        :provider => self.class.provider_name,
        :weather_provider_id => id
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
        :provider => self.class.provider_name,
        :weather_provider_id => id
      }
    ]

    #puts data.inspect
    #exit!

    return data
  end
end
