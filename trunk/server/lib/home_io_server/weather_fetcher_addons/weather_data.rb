require "weather_fetcher"
require "yaml"

# Server fetching weather

module WeatherFetcher
  class WeatherData

    # temp fix
    #attr_reader :metar_string, :rain_metar, :snow_metar

    def to_ar(city)
      if self.provider == 'MetarProvider'
        ar = WeatherMetarArchive.where(city_id: city[:id], time_from: self.time_from).first
        ar = WeatherMetarArchive.new if ar.nil?

        ar.rain_metar = self.rain_metar
        ar.snow_metar = self.snow_metar
        ar.raw = self.metar_string
      else
        wp = WeatherProvider.find_by_name(self.provider)
        wp = WeatherProvider.create!(name: self.provider) if wp.nil?
        ar = WeatherArchive.where(city_id: city[:id], time_from: self.time_from, weather_provider_id: wp.id).first
        ar = WeatherArchive.new if ar.nil?
        ar.weather_provider = wp

        ar.rain = self.rain
        ar.snow = self.snow
      end

      ar.time_from = self.time_from
      ar.time_to = self.time_to
      ar.temperature = self.temperature
      ar.wind = self.wind
      ar.pressure = self.pressure
      ar.city_id = city[:id]

      return ar
    end
  end
end