require 'lib/jabber_bot'
require 'test/unit'

class SimpleReplier
  def self.reply( m )
    puts m.chat_state

    return {
      :to => m.from,
      :body => m.body,
      :subject => 'Test',
      :type => :chat,
      :id => '1'
    }
  end
end

class TestUsartOnline < Test::Unit::TestCase

  def test_simple
    j = JabberBot.new( 'wiatrak_lakie@jabbim.pl', 'antek')

    j.set_replier( SimpleReplier )

    j.start_bot
    loop do
      sleep(1)
    end
  end

end
