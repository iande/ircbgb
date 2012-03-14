require File.expand_path('../../spec_helper', __FILE__)

describe Ircbgb::Client do
  include Stubz

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
    it "sets up servers" do
      client.servers.must_equal [
        'irc://server1.example.org',
        'irc://server2.example.com:7001'
      ]
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

  describe "attribs" do
    it "sets servers from a single string" do
      client.servers = 'irc://foo.bar.bazz'
      client.servers.must_equal [ 'irc://foo.bar.bazz' ]
    end

    it "sets servers from an array" do
      client.servers = [ 'frosty', 'snowman' ] 
      client.servers.must_equal [ 'frosty', 'snowman' ]
    end

    it "sets nicks from a single string" do
      client.nicks = 'peaches'
      client.nicks.must_equal [ 'peaches' ]
    end

    it "sets nicks from an array" do
      client.nicks = ['meaty', 'meaty', 'moo']
      client.nicks.must_equal ['meaty', 'meaty', 'moo']
    end

    it "parses server uris" do
      client.uris.first.host.must_equal 'server1.example.org'
      client.uris.first.port.must_equal 6667
      client.uris.last.host.must_equal 'server2.example.com'
      client.uris.last.port.must_equal 7001
    end
  end

  describe "starting and stopping" do
    before do
      @mock_io = MiniTest::Mock.new
      stub(::IoUnblock::TcpSocket, :new, @mock_io)
    end

    it "starts and stops an unblocked tcp socket and waits until its running" do
      @mock_io.expect(:start, nil)
      @mock_io.expect(:running?, true)
      @mock_io.expect(:stop, nil)
      client.start
      client.stop
      @mock_io.verify
    end
  end

  describe "io" do
  end
end
