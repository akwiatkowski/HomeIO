require 'meas_receiver'

module HomeIoServer
  module DefaultCommConfig
    FORCE = true

    # TODO clean this sh.. up
    def default_comm_config(force = FORCE)
      if MeasReceiver::CommProtocol.host.nil? or force
        MeasReceiver::CommProtocol.host = '192.168.0.7'
      end
      if MeasReceiver::CommProtocol.port.nil? or force
        MeasReceiver::CommProtocol.port = '2002'
      end
    end

  end
end