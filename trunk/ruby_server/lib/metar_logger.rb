require 'singleton'
require './lib/utils/config_loader.rb'
require './lib/metar/metar_constants.rb'
require './lib/metar/metar_ripper/metar_ripper.rb'
require './lib/metar/metar_code.rb'


# Singleton for fetching and sharing metars to other classes

class MetarLogger
  include Singleton

  attr_reader :cities
  
  def initialize
    # TODO - użyj tej klasy do pobrania metar
    # ewentualnie jakaś dodatkowa metoda, dziedzinienie na home io config loader
    @cities = ConfigLoader.instance.config( MetarConstants::CONFIG_TYPE )

    puts "#{self.class.to_s} init - #{@cities.size} cities"
    # cits = @cities.collect{|c| "#{c[:code]} (#{c[:name].to_s})"}
    # puts "Cities: #{cits.join(", ")}"
  end

  # Fetch and store metar for city
  # Use all sites
  def fetch_and_store_city( metar_city )
    year = Time.now.year
    month = Time.now.month

    # fetch metars
    m = MetarRipper.instance
    o = m.fetch( metar_city )

    # process them
    # *metar_array* - array of processed metars
    metar_array = MetarCode.process_array( o , year, month )

    # store them
    metar_array.each do |ma|
      ma.store
    end

    puts metar_array.inspect
  end




end
