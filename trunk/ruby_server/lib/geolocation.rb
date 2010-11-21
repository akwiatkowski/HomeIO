require 'rubygems'
require 'geokit'
require 'lib/config_loader'

# Proxy for geokit gem

class Geolocation
  #attr_accessor :lat, :lon

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

  def self.distance( new_lat = lat, new_lon = lon )
    config = ConfigLoader.instance.config( self.class )
    geo = Geokit::LatLng.new( config[:site][:lat], config[:site][:lon] )
    other_point = Geokit::LatLng.new( new_lat, new_lon )
    return geo.distance_from( other_point )
  end

  def distance( new_lat = lat, new_lon = lon)
    @other_point = Geokit::LatLng.new( new_lat, new_lon )
    return @geo.distance_from( @other_point )
  end

end
