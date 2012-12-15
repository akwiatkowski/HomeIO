#require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'spec_helper'

describe HomeIoServer::RedisProxy do
  it "should simple set/get" do
    d = [1, 2]
    HomeIoServer::RedisProxy.set(:a, d)
    HomeIoServer::RedisProxy.get(:a).should == d
  end
end
