require 'rubygems'
require 'geokit'
require './lib/utils/config_loader.rb'

# Proxy for geokit gem

class Geolocation
  DEFAULT_OPTIONS = {
    :units => :kms,
    :formula => :sphere
  }
  #attr_accessor :lat, :lon

  # location within this distance is threated like the same city [km]
  CITY_DISTANCE_TOLERANCE = 25

  def initialize( lat = nil, lon = nil )
    @config = ConfigLoader.instance.config( self.class )
    @_lat = lat.nil? ? @config[:site][:lat] : lat
    @_lon = lon.nil? ? @config[:site][:lon] : lon
    @geo = Geokit::LatLng.new( @_lat, @_lon )
  end

  def lat
    @geo.lat
  end

  def lon
    @geo.lng
  end

  def lng
    @ge.lng
  end

  # Calculate distance in km from installation site
  def self.distance( new_lat, new_lon )
    config = ConfigLoader.instance.config( self.new.class.to_s )
    geo = Geokit::LatLng.new( config[:site][:lat], config[:site][:lon] )
    other_point = Geokit::LatLng.new( new_lat, new_lon )
    return geo.distance_to( other_point, DEFAULT_OPTIONS )
  end

  # Calculate distance in km from installation site
  def distance( new_lat = lat, new_lon = lon)
    @other_point = Geokit::LatLng.new( new_lat, new_lon )
    return @geo.distance_to( @other_point, DEFAULT_OPTIONS )
  end

  # Calculate distance in km between 2 points
  def self.distance_2points( lat_from, lon_from, lat_to, lon_to )
    geo = Geokit::LatLng.new( lat_from, lon_from )
    other_point = Geokit::LatLng.new( lat_to, lon_to )
    return geo.distance_to( other_point, DEFAULT_OPTIONS )
  end

end
