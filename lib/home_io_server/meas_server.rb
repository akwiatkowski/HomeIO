require 'meas_receiver'
require 'yaml'
require 'logger'
require 'home_io_server/io_comm/default_comm_config'

# Fetch and store_to_buffer measurements

module HomeIoServer
  class MeasServer
    include DefaultCommConfig

    CONFIG_FILE_PATH = File.join("config", "backend", "meas.yml")

    def initialize
      @config = YAML.load(File.open(CONFIG_FILE_PATH))
      @logger = HomeIoLogger.l('meas_server')
      @logger_level = Logger::DEBUG

      default_comm_config

      # AR objects for all types
      @meas_types = Hash.new
      # MeasTypeReceiver objects for all types
      @receivers = Array.new

      @mutex = Mutex.new
      # AR objects to store
      @ar_buffer = Array.new

      @config[:array].each do |c|
        # initialize AR objects
        ar = MeasType.find_or_create_by_name(c[:name])
        if ar.params.blank?
          ar.params = c
          ar.save!
        end

        c[:storage][:proc] = Proc.new { |d| store_to_buffer(c[:name], d) }
        c[:logger] ||= Hash.new
        c[:logger][:level] = @logger_level
        c[:after_proc] = Proc.new { |m| publish_measurement(c[:name], m) }
        c[:ar] = ar

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

    def stop
      @receivers.each do |r|
        r.start
      end
    end

    # Move meas to store buffer
    def store_to_buffer(name, data)
      @mutex.synchronize do
        data.each do |d|
          ar = MeasArchive.new(d)
          ar.meas_type = @meas_types[name]
          @ar_buffer << ar
        end
      end

      flush_store_bugger!
    end

    # Save all measurements to AR/txt file
    def flush_store_bugger!
      @mutex.synchronize do
        ActiveRecord::Base.transaction do

          @ar_buffer.each do |ar|
            ar.save!
          end

          @ar_buffer = Array.new

        end
      end
    end

    # Publish for node.js magic
    def publish_measurement(name, meas)
      m = meas.clone
      m[:name] = name
      m[:time] = m[:time].to_f
      HomeIoServer::RedisProxy.publish('pubsub', { meas: m })
    end

  end
end