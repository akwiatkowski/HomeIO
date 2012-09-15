# Weather providers

class WeatherProvider < ActiveRecord::Base
  has_many :weather_archives

  validates_uniqueness_of :name
  validates_presence_of :name
end
