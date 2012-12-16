require "logger"
require "singleton"

# Storage in DB

module HomeIoServer
  class Storage
    include Singleton

    TYPE = ENV["RAILS_ENV"] || 'development'

    def initialize
      @config = YAML.load(File.open("config/database.yml"))
      @connection = @config[TYPE]

      ActiveRecord::Base.logger = HomeIoLogger.l('active_record')
      ActiveRecord::Base.establish_connection(@connection)
    end

  end
end