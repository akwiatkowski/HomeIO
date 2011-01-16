# METAR archives

class WeatherMetarArchive < ActiveRecord::Base
  belongs_to :city

  validates_uniqueness_of :raw, :scope => :time_from
  validates_uniqueness_of :city_id, :scope => :time_from
  validates_presence_of :raw, :time_from, :city_id
end
