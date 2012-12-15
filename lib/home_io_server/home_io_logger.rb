require 'logger'
require 'fileutils'
require 'colorize'

# Logger helper

LOGS_PATH = File.join('data', 'logs')
FileUtils.mkdir_p LOGS_PATH unless File.exists?(LOGS_PATH)

module HomeIoServer
  class HomeIoLogger

    def self.dev_mode!(l = 1)
      @@dev_mode = l

      l('logger').debug("Logger in dev mode, on level #{l}")
    end

    def self.production_mode!
      @@dev_mode = false
    end

    def self.l(name)
      ns = name.to_s
      f = File.join(LOGS_PATH, "#{name}.log")
      f = STDOUT if defined? @@dev_mode and @@dev_mode

      @@logs = Hash.new unless defined? @@logs
      if @@logs[ns].nil?
        @@logs[ns] = Logger.new(f)

        if defined? @@dev_mode and @@dev_mode > 1
          @@logs[ns].level = Logger::DEBUG
        else
          @@logs[ns].level = Logger::INFO
        end

        l('logger').debug("Created logger object for '#{ns}'")
      end

      return @@logs[name.to_s]
    end

  end
end