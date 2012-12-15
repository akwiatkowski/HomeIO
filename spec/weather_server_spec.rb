require 'spec_helper'

describe HomeIoServer::WeatherServer do
  it "simple" do
    HomeIoServer::HomeIoLogger.dev_mode!(1)
    
    ws = HomeIoServer::WeatherServer.new
    #ws.dev_mode!
    ws.start
    
    loop do
      sleep 60
    end
  end
end
