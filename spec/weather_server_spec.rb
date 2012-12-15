require 'spec_helper'

describe HomeIoServer::WeatherServer do
  it "checking by weather archive count" do
    ws = HomeIoServer::WeatherServer.new

    c = WeatherArchive.count

    ws.dev_mode!
    ws.start
    
    sleep 20

    d = WeatherArchive.count

    d.should > c
  end
end
