require 'singleton'
require 'redis'
#require 'yajl' # segfault # TODO update RVM+ruby
require 'json'

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
      # segfault
      #@parser = Yajl::Parser.new
      #@encoder = Yajl::Encoder.new
      @parser = JSON
      @encoder = JSON
    end

    def encode(data)
      #@encoder.encode(data)
      return JSON.generate(data)
    end

    def parse(string)
      #@parser.parse(string)
      return JSON.parse(string)
    end

  end
end