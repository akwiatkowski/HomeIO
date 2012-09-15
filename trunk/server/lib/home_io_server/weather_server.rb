require "weather_fetcher"

# Server fetching weather

module HomeIoServer
  class WeatherServer

    def initialize
      @scheduler = Rufus::Scheduler.start_new
      @scheduler.every '1s' do
        puts 'check blood pressure'
      end
    end

  end
end