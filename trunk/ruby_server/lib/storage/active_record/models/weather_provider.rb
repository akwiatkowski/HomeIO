# Weather provider
# Has class for non-metar weather aquisition

class WeatherProvider < ActiveRecord::Base
  has_many :weather_archives

  validates_uniqueness_of :name
  validates_presence_of :name

  # Create weather providers from configuration
  def self.create_from_config
    puts "populating weather providers"

    WeatherCityProxy.instance.cities_array.each do |c|
      arc = City.find_by_id( c[:id] ).nil? ? City.new : City.find_by_id( c[:id] )
      arc.name = c[:name]
      arc.country = c[:country]
      arc.metar = c[:metar]
      arc.id = c[:id]
      arc.lat = c[:lat]
      arc.lon = c[:lon]
      arc.safe_save
    end

    #City.transaction do
    #  self.create_from_config_metar
    #  self.create_from_config_nonmetar
    #end
  end

end
