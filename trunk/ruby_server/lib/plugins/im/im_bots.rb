require 'singleton'
#require './lib/comms/im_processor.rb'
require './lib/comms/im_command_resolver.rb'
require './lib/comms/tcp_command_resolver.rb'
Dir["./lib/plugins/im/bots/*.rb"].each {|file| require file }

# Load and start IM bots

class ImBots
  include Singleton

  attr_reader :bots

  def initialize
    @config = ConfigLoader.instance.config( self.class )
    #@processor = ImCommandResolver.instance
    @processor = TcpCommandResolver.instance
    @bots = [
      #Jabber4rBot.instance, # errors
      GaduBot.instance,
      Xmpp4rBot.instance,
    ]
  end

  def start
    @bots.each do |b|
      b.processor = @processor
      b.start
    end

    if true == @config[:run_autoupdater]
      require './lib/plugins/im/im_autoupdated_status.rb'
      ImAutoupdatedStatus.instance.run_autoupdater
    end
  end
end
