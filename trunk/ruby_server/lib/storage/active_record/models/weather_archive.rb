# Weather archives, non-metar

class WeatherArchive < ActiveRecord::Base
  belongs_to :city
  belongs_to :weather_provider

  validates_uniqueness_of :time_from, :scope => [:weather_provider_id, :city_id, :time_to]
  validates_presence_of :time_from, :time_to, :city_id, :weather_provider_id

  # This was stored based by future prediction
  def predicted?
    if self.updated_at >= self.time_from
      return false
    else
      return true
    end
  end

end
