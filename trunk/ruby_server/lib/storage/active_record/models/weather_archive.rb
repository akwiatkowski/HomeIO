# Weather archives, non-metar

class WeatherArchive < ActiveRecord::Base
  belongs_to :city
  belongs_to :weather_provider

  # This was stored based by future prediction
  def predicted?
    if self.updated_at >= self.time_from
      return false
    else
      return true
    end
  end

end
