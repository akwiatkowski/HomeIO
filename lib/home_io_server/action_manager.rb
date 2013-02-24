require 'meas_receiver'
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

      @config[:array].each do |c|
        # initialize AR objects
        ar = ActionType.find_or_create_by_name(c[:name])
        if ar.params.blank?
          ar.params = c
          ar.save!
        end

        @logger.debug("Action manager: added #{c[:name].red}")
      end

    end

  end
end