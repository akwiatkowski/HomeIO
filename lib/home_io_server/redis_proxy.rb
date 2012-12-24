require 'singleton'
require 'redis'
require 'yajl'

# IPC for HomeIO

module HomeIoServer
  class RedisProxy
    include Singleton

    def initialize
      @redis_global = Redis.new
      @redis = Redis::Namespace.new(:homeio, redis: @redis_global)
      init_serializer
    end

    def self.set(_where, _content)
      instance.set(_where, _content)
    end

    def set(_where, _content)
      @redis.set(key(_where), encode(_content))
    end

    def self.get(_where)
      instance.get(_where)
    end

    def get(_where)
      str = @redis.get(key(_where))
      parse(str)
    end

    def self.publish(_where, _content)
      instance.publish(_where, _content)
    end

    def publish(_where, _content)
      @redis.publish(key(_where), encode(_content))
    end

    def key(_where)
      _where.to_s
    end

    def init_serializer
      @parser = Yajl::Parser.new
      @encoder = Yajl::Encoder.new
    end

    def encode(data)
      @encoder.encode(data)
    end

    def parse(string)
      @parser.parse(string)
    end

  end
end