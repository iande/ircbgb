require File.expand_path('../../spec_helper', __FILE__)

describe Ircbgb::MessageParser do
  def parse_it str
    Ircbgb::MessageParser.parse ":#{str}\r\n"
  end

  it "parses user message without args" do
    msg = parse_it 'my_nick!~my|user_[nam{@some.host   KiCk'
    msg.source.nick.must_equal 'my_nick' # just to enusre we've got a user proper
    msg.source.to_s.must_equal 'my_nick!~my|user_[nam{@some.host'
    msg.command.must_equal 'KICK'
    msg.params.must_equal []
  end

  it "parses user message with args" do
    msg = parse_it '[slappy-!~figgle@scrappy.dappy.doo 919 a1,a11   b2.3    c3:88'
    msg.source.to_s.must_equal '[slappy-!~figgle@scrappy.dappy.doo'
    msg.command.must_equal '919'
    msg.params.must_equal ['a1,a11', 'b2.3', 'c3:88']
  end

  it "parses user message with rest" do
    msg = parse_it 'my_nick!my.user@my.host    PRIVmsg  :this  maintains   the spaces  '
    msg.source.to_s.must_equal 'my_nick!my.user@my.host'
    msg.command.must_equal 'PRIVMSG'
    msg.params.must_equal ['this  maintains   the spaces  ']
  end

  it "parses user message with args and rest" do
    msg = parse_it 'my_nick!my.user@my.host  part  #channel1,&channel2   limey :MOA:R  SP:ACES!'
    msg.source.to_s.must_equal 'my_nick!my.user@my.host'
    msg.command.must_equal 'PART'
    msg.params.must_equal ['#channel1,&channel2', 'limey', 'MOA:R  SP:ACES!']
  end

  it "parses server message without args" do
    msg = parse_it 'sweet.server  302'
    msg.source.nick.must_equal 'sweet.server'
    msg.source.to_s.must_equal 'sweet.server'
    msg.command.must_equal '302'
    msg.params.must_equal []
  end

  it "parses server message with args" do
    msg = parse_it 'sweet.server  noticed  a1   a2,a3  a4:5'
    msg.source.to_s.must_equal 'sweet.server'
    msg.command.must_equal 'NOTICED'
    msg.params.must_equal ['a1', 'a2,a3', 'a4:5']
  end

  it "parses server message with rest" do
    msg = parse_it 'sweet.server  quit           :this   has spaces    !'
    msg.source.to_s.must_equal 'sweet.server'
    msg.command.must_equal 'QUIT'
    msg.params.must_equal ['this   has spaces    !']
  end

  it "parses server message with args and rest" do
    msg = parse_it 'sweet.server  Pezz    fright,:clap  beddy pram   :this : has : colons!'
    msg.source.to_s.must_equal 'sweet.server'
    msg.command.must_equal 'PEZZ'
    msg.params.must_equal ['fright,:clap', 'beddy', 'pram', 'this : has : colons!']
  end

  it "parses ipv4 user hosts" do
    msg = parse_it 'me!~notyou@123.45.67.89 mklame'
    msg.source.host.must_equal '123.45.67.89'
  end

  it "parses ipv6 user hosts" do
    msg = parse_it 'me!~notyou@00f:a221:03:e:1234:420b:f6:9a mklame'
    msg.source.host.must_equal '00f:a221:03:e:1234:420b:f6:9a'
  end

  it "parses ipv4 over ipv6 hosts" do
    msg = parse_it 'me!~notyou@0:0:0:0:0:0:1.2.3.4 mklame'
    msg.source.host.must_equal '0:0:0:0:0:0:1.2.3.4'
    msg = parse_it 'me!~notyou@0:0:0:0:0:FffF:1.2.3.4 mklame'
    msg.source.host.must_equal '0:0:0:0:0:FffF:1.2.3.4'
  end

  it "does not parse malformed messages" do
    lambda {
      parse_it 'invalid'
    }.must_raise ::Ircbgb::MessageFormatError

    lambda {
      parse_it 'nick!user@hostname.com       '
    }.must_raise ::Ircbgb::MessageFormatError

    lambda {
      parse_it ''
    }.must_raise ::Ircbgb::MessageFormatError

    lambda {
      parse_it '       '
    }.must_raise ::Ircbgb::MessageFormatError
  end
end
