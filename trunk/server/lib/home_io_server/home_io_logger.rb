require 'logger'
require 'fileutils'

# Logger helper

LOGS_PATH = File.join('data', 'logs')
FileUtils.mkdir_p path unless File.exists?(LOGS_PATH)

module HomeIoServer
  class HomeIoLogger

    def self.dev_mode!(l = 1)
      @@dev_mode = true

      l('logger').debug("Logger in dev mode")
    end

    def self.production_mode!
      @@dev_mode = false
    end

    def self.l(name)
      ns = name.to_s
      f = File.join(LOGS_PATH, "#{name}.log")
      f = STDOUT if @@dev_mode

      @@logs = Hash.new unless defined? @@logs
      if @@logs[ns].nil?
        @@logs[ns] = Logger.new(f)

        if @@dev_mode
          @@logs[ns].level = Logger::DEBUG
        end

        l('logger').debug("Created logger object for '#{ns}'")
      end

      return @@logs[name.to_s]
    end

  end
end