# Interface for objectw which could be stored

module StorageInterface
  # Convert to hash object prepared to store in DB
  def to_db_data
    raise "Not implemented"

    return {
          :data => {},
          :columns => [],
        }

    #    return {
    #      :data => {
    #        :time_created => Time.now,
    #        :time_from => @output[:time].to_i,
    #        :time_to => (@output[:time].to_i + 30*60), # TODO przenieść do stałych
    #        :temperature => @output[:temperature],
    #        :pressure => @output[:pressure],
    #        :wind_kmh => @output[:wind],
    #        :wind => @output[:wind].nil? ? nil : @output[:wind].to_f / 3.6,
    #        :snow_metar => @snow_metar,
    #        :rain_metar => @rain_metar,
    #        :provider => 'METAR',
    #        :raw => @metar_string,
    #        :city_id => @city_id,
    #        :city => @city,
    #        :city_hash => @city_hash
    #      },
    #      :columns => [
    #        :time_created, :time_from, :time_to, :temperature, :pressure, :wind,
    #        :snow, :rain, :city_id, :raw
    #      ]
    #    }
  end
end
