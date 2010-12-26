require 'singleton'
require './lib/utils/config_loader.rb'
require './lib/metar/metar_constants.rb'
require './lib/metar/metar_ripper/metar_ripper.rb'
require './lib/metar/metar_code.rb'
require './lib/metar/metar_mass_processor.rb'

# Singleton for fetching and sharing metars to other classes

class MetarLogger
  include Singleton

  attr_reader :cities
  
  def initialize
    # TODO - użyj tej klasy do pobrania metar
    # ewentualnie jakaś dodatkowa metoda, dziedzinienie na home io config loader
    @cities = ConfigLoader.instance.config( self.class.to_s )[:cities]
    
    puts "#{self.class.to_s} init - #{@cities.size} cities"
    # cits = @cities.collect{|c| "#{c[:code]} (#{c[:name].to_s})"}
    # puts "Cities: #{cits.join(", ")}"

    # deadlock, bad deadlock!
    #@processor = MetarMassProcessor.new
  end

  # Fetch and store metar for all cities
  #
  # Return hash of arrays with MetarCodes
  def fetch_and_store
    h = Hash.new
    @cities.each do |c|
      metar_code = c[:code]
      h[ metar_code ] = fetch_and_store_city( metar_code )
    end
    return h
  end

  # Fetch and store metar for city
  # Use all sites
  #
  # Return array of MetarCode
  def fetch_and_store_city( metar_city )
    year = Time.now.year
    month = Time.now.month

    # fetch metars
    m = MetarRipper.instance
    o = m.fetch( metar_city )

    # process them
    # *metar_array* - array of processed metars
    metar_array = MetarCode.process_array( o , year, month, MetarConstants::METAR_CODE_JUST_DOWNLOADED )

    # store them
    metar_array.each do |ma|
      # store as they were just downloaded
      ma.store
    end

    return metar_array
  end

  # Run processing of
  #def process_all
  #  @processor.process_all
  #end



end
