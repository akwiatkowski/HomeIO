# Cities

class City < ActiveRecord::Base
  has_many :weather_metar_archives
  has_many :weather_archives

  validates_presence_of :country, :name, :lat, :lon
  validates_uniqueness_of :name, :scope => [:lat, :lon]
  validates_uniqueness_of :name, :scope => [:country]
  validates_uniqueness_of :metar, :allow_nil => true

  # cities located within this radius are local
  LOCAL_CITY_LIMIT = 40

  scope :local, lambda { where("calculated_distance < ?", LOCAL_CITY_LIMIT) }
  scope :within_range, lambda { |d| where("calculated_distance <= ?", d.to_f) }
end
