require File.expand_path('../../spec_helper', __FILE__)

describe Ircbgb::Message do
  def client_message *args
    @client_message ||= Ircbgb::Message.new(
      'CMD',
      ['all', 'the', 'pretty little args'],
      Ircbgb::User.parse("nick!~user@some.host.name")
    )
  end

  def server_message
    @server_message ||= Ircbgb::Message.new(
      '303',
      [],
      Ircbgb::Server.new('host.domain.tld')
    )
  end

  it "parses the source" do
    client_message.source.to_s.must_equal "nick!~user@some.host.name"
    server_message.source.to_s.must_equal "host.domain.tld"
  end

  it "parses the command" do
    client_message.command.must_equal 'CMD'
    server_message.command.must_equal '303'
  end

  it "parses the parameters" do
    client_message.params.must_equal ['all', 'the', 'pretty little args']
    server_message.params.must_equal []
  end

  it "identifies a numeric reply" do
    client_message.numeric?.must_equal false
    server_message.numeric?.must_equal true
  end

  describe "to_s without source" do
    def irc_message cmd, *params
      Ircbgb::Message.new cmd, params, nil
    end

    it "converts properly without params" do
      msg = irc_message 'PRIVMSG'
      msg.to_s.must_equal 'PRIVMSG'
      new_msg = Ircbgb::MessageParser.parse("#{msg.to_s}\r\n")
      new_msg.to_s.must_equal msg.to_s
    end

    it "converts properly with single word params" do
      msg = irc_message 'ison', 'a', 'b,d', 'c'
      msg.to_s.must_equal 'ISON a b,d c'
      new_msg = Ircbgb::MessageParser.parse("#{msg.to_s}\r\n")
      new_msg.to_s.must_equal msg.to_s
    end

    it "converts properly when a trailing param contains a space" do
      msg = irc_message 'notICE', 'a,b,c', 'this contains spaces'
      msg.to_s.must_equal 'NOTICE a,b,c :this contains spaces'
      new_msg = Ircbgb::MessageParser.parse("#{msg.to_s}\r\n")
      new_msg.to_s.must_equal msg.to_s
    end

    it "converts properly when a non-trailing param contains a space" do
      msg = irc_message 'privmsg', 'a,b', 'this is a', 'final', 'test'
      msg.to_s.must_equal 'PRIVMSG a,b :this is a final test'
      new_msg = Ircbgb::MessageParser.parse("#{msg.to_s}\r\n")
      new_msg.to_s.must_equal msg.to_s
    end
  end

  describe "to_s with source" do
    def irc_message src
      Ircbgb::Message.new 'PRIVMSG', ['this', 'is my', 'list of', 'params'], src
    end

    it "converts properly with a user" do
      msg = irc_message Ircbgb::User.new('nickname', '~user', 'my.host.name')
      msg.to_s.must_equal ':nickname!~user@my.host.name PRIVMSG this :is my list of params'
      new_msg = Ircbgb::MessageParser.parse("#{msg.to_s}\r\n")
      new_msg.to_s.must_equal msg.to_s
    end

    it "converts properly with a server" do
      msg = irc_message Ircbgb::Server.new('irc.server.host.name')
      msg.to_s.must_equal ':irc.server.host.name PRIVMSG this :is my list of params'
      new_msg = Ircbgb::MessageParser.parse("#{msg.to_s}\r\n")
      new_msg.to_s.must_equal msg.to_s
    end
  end
end
