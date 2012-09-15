require "active_record"
require "active_record/connection_adapters/postgresql_adapter"
require "logger"
require "singleton"

require "home_io_server/models/city"
require "home_io_server/models/weather_archive"
require "home_io_server/models/weather_metar_archive"
require "home_io_server/models/weather_provider"

# Storage in DB

module HomeIoServer
  class Storage
    include Singleton

    def initialize
      @config = YAML.load(File.open("config/active_record.yml"))
      @connection = @config[:connection]

      ActiveRecord::Base.logger = Logger.new(STDERR)
      ActiveRecord::Base.logger.level = Logger::INFO
      ActiveRecord::Base.establish_connection(@connection)
    end

  end
end