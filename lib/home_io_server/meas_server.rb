require 'meas_receiver'
require 'yaml'

# Everything

module HomeIoServer
  class MeasServer
    def initialize
      @config = YAML.load(File.open("config/meas.yml"))

      MeasReceiver::CommProtocol.host = '192.168.0.13'
      MeasReceiver::CommProtocol.port = '2002'

      @receivers = Array.new

      @config.each do |c|
        m = MeasReceiver::MeasTypeReceiver.new(c)
        @receivers << m
      end
    end

  end
end