require 'net/http'
require 'rubygems'
require 'hpricot'
require 'lib/db_store'


class WeatherBase

  def check_all
    @defs.each do |d|
      # TODO rescue do pobierania i pretwarzania, aby logger zapisywał że był błąd
      #begin
        check_online( d )
      #rescue
      #end
    end
    DbStore.instance.flush
  end

  private

  def check_online( defin )
    body = fetch( defin )
    processed = process( body )
    store( processed, defin )
    return processed
  end

  def fetch( defin )
    body = Net::HTTP.get( URI.parse( defin[:url] ) )
    #puts body
    f = File.new('delme.txt','w')
    f.puts body
    f.close
    return body
  end

  def store( data, defin )
    # TODO czy tych danych nie ma w plikach konf
    # metar logger base
    f = File.new( File.join("data", "weather", self.class.to_s+".txt"), "a")
    data.each do |d|
      f.puts("#{d[:time_created].to_i}; '#{defin[:city].to_s}'; #{d[:provider].to_s}; #{defin[:coord][:lat]}; #{defin[:coord][:lon]};   #{d[:time_from].to_i}; #{d[:time_to].to_i}; #{d[:temperature]}; #{d[:wind]}; #{d[:pressure]}; #{d[:rain]}; #{d[:snow]}")
      DbStore.instance.store_weather_data( d, defin )

      puts "#{defin[:city].to_s}"
    end
    f.close
  end

end
