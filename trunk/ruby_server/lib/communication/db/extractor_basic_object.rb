require "lib/communication/db/extractor_active_record"

# Wrap extractor to communicate only using basic object (Hashes, Arrays)
# So no AR objects will be send via sockets

class ExtractorBasicObject < ExtractorActiveRecord

  # Get all cities
  def get_cities
    cities = super
    attrs  = cities.collect { |c| {
        :name    => c.attributes["name"],
        :country => c.attributes["country"],
        :lat     => c.attributes["lat"],
        :lon     => c.attributes["lon"],
        :id      => c.attributes["id"],
    } }
    puts attrs.inspect
    return attrs
  end

end