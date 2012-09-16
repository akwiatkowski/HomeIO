require "weather_fetcher"
require "yaml"

# Server fetching weather

module WeatherFetcher
  class WeatherData

    def metar_code
      self.city_hash[:metar]
    end

    def to_ar
      city = self.city_hash

      if is_metar?
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

    def to_text
      s = ""
      s += "#{self.time_created.to_i}; "
      s += "'#{self.city_hash[:name].to_s}'; "
      s += "#{self.provider.to_s}; "
      s += "#{self.city_hash[:coords][:lat]}; "
      s += "#{self.city_hash[:coords][:lon]};   "
      s += "#{self.time_from.to_i}; "
      s += "#{self.time_to.to_i}; "
      s += "#{self.temperature}; "
      s += "#{self.wind}; "
      s += "#{self.pressure}; "
      s += "#{self.rain};"
      s += "#{self.snow}"
      return s
    end

    # String used for checking uniqueness and for overwriting old weather data
    def uniq_hash
      return "#{self.provider}_#{self.city_hash[:name]}_#{self.city_hash[:country]}_#{self.time_from.to_i}_#{self.metar_string}"
    end

    def self.uniq(_array)
      h = Hash.new
      # reverse order
      _array.sort { |a, b| b.time_created <=> a.time_created }.each { |e| h[e.uniq_hash] = e }
      return h.values
    end

  end
end