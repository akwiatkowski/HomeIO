require 'rubygems'
require 'panoramio'


class PanoramioTest
  def initialize
    url = Panoramio.url(:minx => 60,
                        :maxx => 70,
                        :miny => 10,
                        :maxy => 20)

    puts url
    #return
    
    photos = Panoramio.photos(:minx => 60,
                              :maxx => 70,
                              :miny => 10,
                              :maxy => 20)

    photo = photos.first

    puts photo.photo_title
    puts photo.latitude
    puts photo.longitude

  end
end

p = PanoramioTest.new