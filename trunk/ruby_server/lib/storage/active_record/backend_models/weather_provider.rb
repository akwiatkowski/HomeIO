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


# Weather provider
# Has class for non-metar weather aquisition

require './lib/storage/active_record/rails_models/weather_provider.rb'

class WeatherProvider

  # Create weather providers from configuration
  def self.create_from_config
    puts "populating weather providers"

    WeatherCityProxy.instance.cities_array.each do |c|
      arc = City.find_by_id( c[:id] ).nil? ? City.new : City.find_by_id( c[:id] )
      arc.name = c[:name]
      arc.country = c[:country]
      arc.metar = c[:metar]
      arc.id = c[:id]
      arc.lat = c[:lat]
      arc.lon = c[:lon]
      arc.safe_save
    end

    #City.transaction do
    #  self.create_from_config_metar
    #  self.create_from_config_nonmetar
    #end
  end

end
