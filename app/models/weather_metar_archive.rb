# METAR archives

class WeatherMetarArchive < ActiveRecord::Base
  belongs_to :city

  validates_uniqueness_of :raw, :scope => :time_from
  validates_uniqueness_of :city_id, :scope => :time_from
  validates_presence_of :raw, :time_from, :city_id

  validates_length_of :raw, :maximum => 200

  scope :city_id, lambda { |city_id| where({:city_id => city_id}) }
end
