require 'meas_receiver'
require 'yaml'

# Everything

module HomeIoServer
  class MeasServer
    CONFIG = File.join("config", "backend", "meas.yml")

    def initialize
      @config = YAML.load(File.open(CONFIG))

      MeasReceiver::CommProtocol.host = '192.168.0.7'
      MeasReceiver::CommProtocol.port = '2002'

      @receivers = Array.new

      @config[:array].each do |c|
        m = MeasReceiver::MeasTypeReceiver.new(c)
        m.fetch
        puts m.last.inspect
        @receivers << m
      end
    end

  end
end