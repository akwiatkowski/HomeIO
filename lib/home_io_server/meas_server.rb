require 'meas_receiver'
require 'yaml'
require 'logger'

# Everything

module HomeIoServer
  class MeasServer
    CONFIG = File.join("config", "backend", "meas.yml")

    def initialize
      @config = YAML.load(File.open(CONFIG))
      @logger = HomeIoLogger.l('meas_server')

      default_comm_config

      @meas_types = Hash.new
      @receivers = Array.new

      @mutex = Mutex.new
      @ar_buffer = Array.new

      @config[:array].each do |c|
        ar = MeasType.find_or_create_by_name(c[:name])
        if ar.params.blank?
          ar.params = c
          ar.save!
        end

        c[:storage][:proc] = Proc.new { |d| store(c[:name], d) }
        c[:logger] ||= Hash.new
        c[:logger][:level] = Logger::DEBUG
        c[:after_proc] = Proc.new { |m| publish_measurement(c[:name], m) }
        c[:ar] = ar

        # DEV
        c[:storage][:store_interval] = 30.0

        m = MeasReceiver::MeasTypeReceiver.new(c)
        @receivers << m
        @meas_types[c[:name]] = ar

        @logger.debug("Meas server: added #{c[:name].red}")
      end

    end

    def start
      @receivers.each do |r|
        r.start
      end
    end

    def store(name, data)
      @mutex.synchronize do
        data.each do |d|
          ar = MeasArchive.new(d)
          ar.meas_type = @meas_types[name]
          @ar_buffer << ar
        end
      end

      store!
    end

    def store!
      @mutex.synchronize do
        ActiveRecord::Base.transaction do

          @ar_buffer.each do |ar|
            ar.save!
          end

          @ar_buffer = Array.new

        end
      end
    end

    def publish_measurement(name, m)
      m[:name] = name
      HomeIoServer::RedisProxy.publish('pubsub', {meas: m})
    end

    def default_comm_config
      if MeasReceiver::CommProtocol.host.nil?
        MeasReceiver::CommProtocol.host = '192.168.0.7'
      end
      if MeasReceiver::CommProtocol.port.nil?
        MeasReceiver::CommProtocol.port = '2002'
      end
    end


  end
end