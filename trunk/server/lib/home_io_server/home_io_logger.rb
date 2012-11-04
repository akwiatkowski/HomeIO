require 'logger'
require 'fileutils'

# Logger helper

LOGS_PATH = File.join('data', 'logs')
FileUtils.mkdir_p path unless File.exists?(LOGS_PATH)

module HomeIoServer
  class HomeIoLogger

    def self.l(name)
      @@logs = Hash.new
      @@logs[name.to_s] ||= Logger.new(File.join(LOGS_PATH,"#{name}.log"))
      @@logs[name.to_s]
    end

  end
end