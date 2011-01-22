require 'singleton'

Dir["./lib/plugins/im/bots/*.rb"].each {|file| require file }

# Load and start IM bots

class ImBots
  include Singleton

  attr_reader :bots

  # there are 2 resolvers
  # direct loads many classes and execute commands now
  COMMAND_RESOLVER_DIRECT = :direct
  # via tcp uses HomeIO task based tcp protocol for all queries
  COMMAND_RESOLVER_VIA_TCP = :via_tcp

  #COMMAND_RESOLVER = COMMAND_RESOLVER_DIRECT
  COMMAND_RESOLVER = COMMAND_RESOLVER_VIA_TCP

  def initialize
    @config = ConfigLoader.instance.config( self.class )

    # commands resolver
    if COMMAND_RESOLVER_DIRECT == COMMAND_RESOLVER
      require './lib/comms/im_command_resolver.rb'
      @processor = ImCommandResolver.instance
    end
    if COMMAND_RESOLVER_VIA_TCP == COMMAND_RESOLVER
      require './lib/comms/tcp_command_resolver.rb'
      @processor = TcpCommandResolver.instance
    end

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
