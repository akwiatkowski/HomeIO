#require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'spec_helper'

describe HomeIoServer::RedisProxy do
  it "should simple set/get" do
    loop do
      puts Time.now
      HomeIoServer::RedisProxy.publish('pubsub', Time.now.to_s)
      
      sleep 1
    end
  end
end
