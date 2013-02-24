require 'meas_receiver'

module HomeIoServer
  module DefaultCommConfig

    # TODO clean this sh..
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