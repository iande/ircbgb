require File.expand_path('../../spec_helper', __FILE__)

describe Ircbgb::Client do
  def client
    @client ||= Ircbgb::Client.new { |c|
      c.servers << 'irc://server1.example.org'
      c.servers << 'irc://server2.example.com:7001'
      c.nicks = ['bot1', 'bot2', 'bot3']
      c.realname = 'I am a bot'
      c.username = 'botty'
    }
  end

  describe "initialize" do 
    it "parses server uris" do
      client.uris.first.host.must_equal 'server1.example.org'
      client.uris.first.port.must_equal 6667
      client.uris.last.host.must_equal 'server2.example.com'
      client.uris.last.port.must_equal 7001
    end

    it "sets up nicknames" do
      client.nicks.must_equal [ 'bot1', 'bot2', 'bot3' ]
    end

    it "sets up a realname" do
      client.realname.must_equal 'I am a bot'
    end

    it "sets up a username" do
      client.username.must_equal 'botty'
    end
  end
end
