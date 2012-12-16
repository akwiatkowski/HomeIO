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

      MeasReceiver::CommProtocol.host = '192.168.0.7'
      MeasReceiver::CommProtocol.port = '2002'

      @ar_objects = Array.new
      @receivers = Array.new

      @config[:array].each do |c|
        ar = MeasType.find_or_create_by_name(c[:name])
        if ar.params.blank?
          ar.params = c
          ar.save!
        end

        c[:storage][:proc] = Proc.new { |d| store(c[:name], d) }
        c[:logger] ||= Hash.new
        c[:logger][:level] = Logger::DEBUG
        c[:ar] = ar

        m = MeasReceiver::MeasTypeReceiver.new(c)
        @receivers << m

        @logger.debug("Meas server: added #{c[:name].red}")
      end

    end

    def start
      @receivers.each do |r|
        r.start
      end
    end

    def store(name, data)
      puts name, data.inspect
    end

  end
end