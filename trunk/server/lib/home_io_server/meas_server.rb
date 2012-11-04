require 'meas_receiver'
require 'yaml'

# Everything

module HomeIoServer
  class MeasServer
    def initialize
      @config = YAML.load(File.open("config/meas.yml"))
      puts @config.to_yaml
    end

  end
end