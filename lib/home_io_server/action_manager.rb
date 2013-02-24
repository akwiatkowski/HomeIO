require 'meas_receiver/comm_protocol'
require 'yaml'
require 'logger'
require 'home_io_server/io_comm/default_comm_config'

# Fetch and store_to_buffer measurements

module HomeIoServer
  class ActionManager
    include DefaultCommConfig

    CONFIG_FILE_PATH = File.join("config", "backend", "action.yml")

    def initialize
      @config = YAML.load(File.open(CONFIG_FILE_PATH))
      @logger = HomeIoLogger.l('meas_server')
      @logger_level = Logger::DEBUG

      default_comm_config

      # AR objects
      @actions = Hash.new
      @config[:array].each do |c|
        # initialize AR objects
        ar = ActionType.find_or_create_by_name(c[:name])
        if ar.params.blank?
          ar.params = c
          ar.save!
        end
        @actions[c[:name]] = ar

        @logger.debug("Action manager: added #{c[:name].red}")
      end

    end

    def execute_by_name(name)
      a = @actions[name]
      return nil if a.nil?

      m = MeasReceiver::CommProtocol.new(a.params[:command][:array], a.params[:command][:response_correct].size)
      return m.get
    end

  end
end