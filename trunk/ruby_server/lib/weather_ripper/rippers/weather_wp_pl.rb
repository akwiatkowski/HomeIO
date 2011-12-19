#!/usr/bin/ruby
#encoding: utf-8

# HomeIO - home control system.
# Copyright (C) 2011 Aleksander Kwiatkowski
#
# This file is part of HomeIO.
#
# HomeIO is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# HomeIO is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with HomeIO.  If not, see <http://www.gnu.org/licenses/>.


require File.join Dir.pwd, 'lib/weather_ripper/rippers/weather_abstract'

# Wp.pl weather processor

class WeatherWpPl < WeatherAbstract

  # Provider name
  def self.provider_name
    "Wp.pl"
  end

  # Process response body and rip out weather data
  def _process(body_raw)

    body  = body_raw.downcase

    # days from detailed weather
    days  = body.scan(/(\d{1,2})\.(\d{1,2})\.(\d{4})/)
    #puts days.inspect
    #puts days.size

    hours = body.scan(/(\d{2})-(\d{2})/)
    hours = hours.select { |h| h[0].to_i <= 24 and h[1].to_i <= 24 }
    #puts hours.inspect
    #puts hours.size

    # create times
    i_day = 0
    times = Array.new

    (0...(hours.size)).each do |ih|
      # next day
      if ih > 0 and hours[ih][0].to_i < hours[ih - 1][0].to_i
        i_day += 1
      end

      # can not create time with hour 24
      hour_from = hours[ih][0].to_i
      hour_from = 0 if hour_from == 24
      time_from = Time.mktime(
          days[i_day][2].to_i,
          days[i_day][1].to_i,
          days[i_day][0].to_i,
          hour_from,
          0,
          0,
          0
      )
      time_from += 24*3600 if hours[ih][0].to_i == 24

      hour_to = hours[ih][1].to_i
      hour_to = 0 if hour_to == 24
      time_to = Time.mktime(
          days[i_day][2].to_i,
          days[i_day][1].to_i,
          days[i_day][0].to_i,
          hour_to,
          0,
          0,
          0
      )
      time_to += 24*3600 if hours[ih][1].to_i == 24

      h = {:time_from => time_from, :time_to => time_to}
      times << h
    end
    # puts times.to_yaml
    #puts times.size

    temperatures = body.scan(/temperatura:\s*<strong>(-?\d+)[^<]*<\/strong>/)
    #puts temperatures.inspect
    #puts temperatures.size

    #winds = body.scan(/<strong>(\d*\.?\d*)\s*km\/h<\/strong>/)
    #winds.slice!(0,5)
    winds        = body.scan(/<td width=\"30%\">[^<]*<strong>(\d*\.?\d*)\s*km\/h<\/strong>/)
    #puts winds.inspect
    #puts winds.size

    data         = Array.new

    (0...(temperatures.size)).each do |i|
      t = temperatures[i][0]
      t = t.to_f unless t.nil?

      wind_speed_km_per_h = winds[i][0]
      if t.nil?
        wind_speed_km_per_h = nil
        w                   = nil
      else
        wind_speed_km_per_h = wind_speed_km_per_h.to_f
        w                   = wind_speed_km_per_h / 3.6
      end

      h = {
          :time_created        => Time.now,
          :time_from           => times[i][:time_from],
          :time_to             => times[i][:time_to],
          :temperature         => t,
          #:pressure => nil,
          :wind_kmh            => wind_speed_km_per_h,
          :wind                => w,
          #:snow => snows[0][0].to_f,
          #:rain => rains[0][0].to_f,
          :provider            => self.class.provider_name,
          :weather_provider_id => id
      }

      data << h
    end

    return data
  end
end
