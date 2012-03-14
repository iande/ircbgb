require File.expand_path('../../spec_helper', __FILE__)
require 'stringio'

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

  describe "connecting" do
    before do
      @socket = socket = DummyIO.new
      @socket.readable = true
      @socket.writeable = true
      meta_socket = class << TCPSocket; self; end
      meta_socket.send(:alias_method, :mangled_new, :new)
      meta_socket.send(:define_method, :new) { |*_| socket }
    end

    after do
      meta_socket = class << TCPSocket; self; end
      meta_socket.send(:remove_method, :new)
      meta_socket.send(:alias_method, :new, :mangled_new)
    end

    it "connects" do
      client.start
      Thread.pass until client.connected?
      client.stop
      @socket.w_stream.string.must_equal "USER botty x y :I am a bot\r\nNICK bot1\r\n"
    end
  end
end
