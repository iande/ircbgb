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
    before do
      @socket = socket = UnblockedTcpSocket.new
      stub(::IoUnblock::TcpSocket, :new) { |*a|
        socket.init_with(*a)
      }
      client.start
    end

    after do
      client.stop
    end

    describe "connecting" do
      it "is connected once it's sent the user nick and pong" do
        client.connected?.must_equal false
        @socket.trigger_start
        @socket.server_write 'PING :give tHi:S baCK!'
        client.connected?.must_equal true
        @socket.written.must_equal [
          'USER botty 0 * :I am a bot',
          'NICK bot1',
          'PONG :give tHi:S baCK!'
        ]
      end

      it "chooses alternate nicknames" do
        @socket.trigger_start
        @socket.server_write '433 * bot1 :Nickname is already in use.'
        client.connected?.must_equal false
        @socket.server_write '433 * bot2 :Nickname is already in use.'
        client.connected?.must_equal false
        @socket.server_write 'PING :0123456'
        client.connected?.must_equal true
        @socket.written.must_equal [
          'USER botty 0 * :I am a bot',
          'NICK bot1',
          'NICK bot2',
          'NICK bot3',
          'PONG :0123456'
        ]
      end

      it "shuts down if all nicknames are taken" do
        @socket.trigger_start
        @socket.server_write '433 * bot1 :Nickname is already in use.'
        @socket.server_write '433 * bot2 :Nickname is already in use.'
        @socket.server_write '433 * bot3 :Nickname is already in use.'
        client.connected?.must_equal false
        @socket.written.must_equal [
          'USER botty 0 * :I am a bot',
          'NICK bot1',
          'NICK bot2',
          'NICK bot3',
          'QUIT'
        ]
      end
    end

    describe "events" do
      it "binds and triggers an event based upon a received command" do
        params = nil
        msg = nil
        client.received 403 do |me, ps, m|
          params = ps
          msg = m
        end
        @socket.server_write '403 these are :my various arguments'
        params.must_equal ['these', 'are', 'my various arguments']
        msg.command.must_equal '403'
        msg.source.nick.must_equal 'server1.example.org'
      end

      it "triggers an event split across multiple reads" do
        params = nil
        msg = nil
        client.received 'ping' do |me, ps, m|
          params = ps
          msg = m
        end

        @socket.server_write_raw ':server1.example.org PI'
        @socket.server_write_raw 'NG :echo this bac'
        @socket.server_write_raw "k to me\r\n"
        params.must_equal ['echo this back to me']
        msg.command.must_equal 'PING'
      end

      it "binds and triggers events based on a command to send" do
        params = nil
        msg = nil
        client.sending 'nick' do |me, ps, m|
          params = ps
          msg = m
        end
        client.do_nick 'ph3ar-'
        params.must_equal [ 'ph3ar-' ]
        msg.command.must_equal 'NICK'
      end

      it "binds and triggers an receiving/received in the right order" do
        response_order = []
        client.received :privmsg do
          response_order << :on
        end
        client.receiving :privmsg do
          response_order << :before
        end
        @socket.server_write 'PRIVMSG #blax0 :hello cruel world!'
        response_order.must_equal [:before, :on]
      end

      it "binds and triggers events based on a command that was sent" do
        params = nil
        msg = nil
        client.sent 'nick' do |me, ps, m|
          params = ps
          msg = m
        end
        client.do_nick 'ph3ar-'
        params.must_equal nil
        @socket.trigger_full_write_callbacks
        params.must_equal [ 'ph3ar-' ]
        msg.command.must_equal 'NICK'
      end
    end
  end
end
