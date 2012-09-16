require 'logger'
require 'fileutils'

# Logger helper

path = 'data/logs'
FileUtils.mkdir_p path unless File.exists?(path)

module HomeIoServer
  class HomeIoLogger

    def self.l(name)
      Logger.new(File.join('data','logs',"#{name}.log"))
    end

  end
end