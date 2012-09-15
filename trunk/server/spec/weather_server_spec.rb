require 'spec_helper'

describe HomeIoServer::WeatherServer do
  it "simple" do
    ws = HomeIoServer::WeatherServer.new
    loop do
      sleep 60
    end
  end
end
