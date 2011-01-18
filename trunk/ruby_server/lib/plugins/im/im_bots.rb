require 'singleton'
Dir["./lib/plugins/im/bots/*.rb"].each {|file| require file }
require './lib/plugins/im/im_autoupdated_status.rb'

# Load and start IM bots

class ImBots
  include Singleton

  attr_reader :bots

  def initialize
    @config = ConfigLoader.instance.config( self.class )

    @bots = [
      #Jabber4rBot.instance, # errors
      Xmpp4rBot.instance,
      GaduBot.instance
    ]
  end

  def start
    @bots.each do |b|
      puts b.start
    end

    if true == @config[:run_autoupdater]
      ImAutoupdatedStatus.instance.run_autoupdater
    end
  end
end

# some links
# http://home.gna.org/xmpp4r/
# http://jabber4r.rubyforge.org/
# http://socket7.net/software/jabber-bot