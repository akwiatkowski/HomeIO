require 'spec_helper'

describe HomeIoServer::WeatherServer do
  it "simple" do
    HomeIoServer::HomeIoLogger.dev_mode!
    
    ws = HomeIoServer::WeatherServer.new
    loop do
      sleep 60
    end
  end
end
