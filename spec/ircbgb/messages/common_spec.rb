require File.expand_path('../../../spec_helper', __FILE__)

describe "common message types" do
  def parse_it str
    Ircbgb::MessageParser.parse "#{str}\r\n"
  end

  it "creates privmsg objects" do
    msg = parse_it('PRIVMSG #a,b,&c :this is my text')
    msg.class.must_equal Ircbgb::Messages::Privmsg
    msg.target.must_equal '#a,b,&c'
    msg.targets.must_equal ['#a', 'b', '&c']
    msg.text.must_equal 'this is my text'
  end

  it "creates notice objects" do
    msg = parse_it('NOTICE #a,b,&c :this is my text')
    msg.class.must_equal Ircbgb::Messages::Notice
    msg.target.must_equal '#a,b,&c'
    msg.targets.must_equal ['#a', 'b', '&c']
    msg.text.must_equal 'this is my text'
  end

  it "creates ctcp request objects" do
    msg = parse_it("PRIVMSG #a,b,&c :\001PING 12345 6789\001")
    msg.class.must_equal Ircbgb::Messages::CtcpRequest
    msg.target.must_equal '#a,b,&c'
    msg.targets.must_equal ['#a', 'b', '&c']
    msg.text.must_equal 'PING 12345 6789'
    msg.request.must_equal 'PING'
  end

  it "creates ctcp response objects" do
    msg = parse_it("NOTICE #a,b,&c :\001PING 12345 6789\001")
    msg.class.must_equal Ircbgb::Messages::CtcpResponse
    msg.target.must_equal '#a,b,&c'
    msg.targets.must_equal ['#a', 'b', '&c']
    msg.text.must_equal 'PING 12345 6789'
    msg.response.must_equal 'PING'
  end

  it "creates join objects" do
    msg = parse_it ':stubby!~slacker@host.name JOIN #pants'
    msg.class.must_equal Ircbgb::Messages::Join
    msg.channel.must_equal '#pants'
  end

  it "creates part objects" do
    msg = parse_it ':stubby!~slacker@host.name PART #pants'
    msg.class.must_equal Ircbgb::Messages::Part
    msg.channel.must_equal '#pants'
    msg.message.must_equal ''

    msg = parse_it ':stubby!~slacker@host.name PART #pants :heading out'
    msg.class.must_equal Ircbgb::Messages::Part
    msg.channel.must_equal '#pants'
    msg.message.must_equal 'heading out'
  end

  it "creates kick objects" do
    msg = parse_it ':stubby!~slacker@host.name KICK #pants dude_fella'
    msg.class.must_equal Ircbgb::Messages::Kick
    msg.channel.must_equal '#pants'
    msg.kicked.must_equal 'dude_fella'
    msg.message.must_equal ''

    msg = parse_it ':stubby!~slacker@host.name KICK #pants dude_fella :time to go'
    msg.class.must_equal Ircbgb::Messages::Kick
    msg.channel.must_equal '#pants'
    msg.kicked.must_equal 'dude_fella'
    msg.message.must_equal 'time to go'
  end
end
