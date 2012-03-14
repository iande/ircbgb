require File.expand_path('../../spec_helper', __FILE__)

describe Ircbgb::Message do
  def client_message *args
    @client_message ||= Ircbgb::Message.new(
      Ircbgb::User.parse("nick!~user@some.host.name"),
      'CMD',
      ['all', 'the', 'pretty little args']
    )
  end

  def server_message
    @server_message ||= Ircbgb::Message.new(
      Ircbgb::Server.new('host.domain.tld'),
      '303',
      []
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
end
