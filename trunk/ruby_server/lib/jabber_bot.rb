require 'rubygems'
require 'xmpp4r/client'
require 'xmpp4r/roster/helper/roster'
require 'xmpp4r/bytestreams'

# Simple repplier class used for creating new
class SimpleReplier
  def self.reply( m )

    # m.chat_state:  :active, :composing, :gone, :inactive, :paused

    return {
      :to => m.from,
      :body => m.body,
      :subject => 'Test',
      :type => :chat,
      :id => '1'
    }
  end
end


class JabberBot
  # obiekt który posiada metodę process zwracającą odpowiedź
  attr_accessor :replier

  include Jabber

  # podłączenie do serwera
  def initialize( login, password )

    @jid = JID::new( login )
    @cl = Client::new( @jid )
    @cl.connect
    @cl.auth(password)

    p = Presence.new
    p.set_type(:available)
    p.set_status(Time.now.to_s)
    @cl.send( p )

    @replier = SimpleReplier
  end

  # Set class for replying
  def set_replier( klass )
    @replier = klass
  end

  # dodaje jid do subskrybowanych
  def subsribe_user( jid )
    pres = Presence.new.set_type(:subscribe).set_to( jid )
    @cl.send(pres)
  end

  # Uruchamia bot odpowiadający i wykonujący polecenia
  def start_bot
    @cl.add_message_callback do |m|
      response = @replier.reply( m )
      send_message( response )
    end
  end

  # Send custom message
  #
  # :to - jid
  # :body - content of message
  # :type:
  # - :normal - single, new window
  # - :chat - normal chat in one window
  # - :error - special info, error
  # - :headline - special info
  def send_message( message )
    m = Message::new( message[:to], message[:body] )
    m.set_type( message[:type] )
    m.set_id( message[:id] )
    m.set_subject( message[:subject] )

    @cl.send m
  end

end
