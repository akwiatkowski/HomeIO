# METAR archives

class WeatherMetarArchive < ActiveRecord::Base
  belongs_to :city

  validates_uniqueness_of :raw, :scope => :time_from
  validates_uniqueness_of :city_id, :scope => :time_from
  validates_presence_of :raw, :time_from, :city_id

  validates_length_of :raw, :maximum => 200
  
  validates :pressure, numericality: { greater_than: 900, less_than: 1200 }, allow_nil: true
  validates :wind, numericality: { greater_than: 0.0, less_than: 300.0 }, allow_nil: true
end
