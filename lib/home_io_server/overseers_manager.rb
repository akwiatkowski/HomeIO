require 'home_io_server/redis_proxy'

module HomeIoServer
  class OverseersManager
    def initialize
      HomeIoServer::RedisProxy.subscribe('admin') do |data, c|
        puts data, c
      end
    end
  end
end
