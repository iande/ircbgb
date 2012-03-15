require File.expand_path('../../spec_helper', __FILE__)

describe Ircbgb::User do
  describe "parsing" do
    it "parses a `nick!user@host` string" do
      user = Ircbgb::User.parse('my_nick!~stuffit@some.exotic.host')
      user.nick.must_equal 'my_nick'
      user.user.must_equal '~stuffit'
      user.host.must_equal 'some.exotic.host'
    end

    it "parses a wildcarded string" do
      user = Ircbgb::User.parse('*!?stuffy@*.example.???')
      user.nick.must_equal '*'
      user.user.must_equal '?stuffy'
      user.host.must_equal '*.example.???'
    end

    it "parses missing bits, wildcarding what's left out" do
      user = Ircbgb::User.parse('beeboz')
      user.nick.must_equal 'beeboz'
      user.user.must_equal '*'
      user.host.must_equal '*'
      user = Ircbgb::User.parse('booboz!@host')
      user.nick.must_equal 'booboz'
      user.user.must_equal '*'
      user.host.must_equal 'host'
    end

    it "parses a user as itself" do
      user = Ircbgb::User.parse('my_nick!~stuffit@some.exotic.host')
      Ircbgb::User.parse(user).must_equal user
    end
  end

  describe "methods" do
    it "converts to a string" do
      user = Ircbgb::User.new('a_nick', 'a_username', 'a.host.example.org')
      user.to_s.must_equal 'a_nick!a_username@a.host.example.org'
      Ircbgb::User.parse('nick').to_s.must_equal 'nick!*@*'
    end
  end

  describe "matching" do
    def match_me; @match_me ||= Ircbgb::User.new('someNick', '~stuffy', 'britches.co.uk'); end
    
    it "matches against IRC wildcard strings" do
      'someNick!~stuffy@britches.co.uk'.must_match match_me
      '*o*!*stuffy@*i*.?o.u?'.must_match match_me
      'S???nick!*~stuffy@britches.co.**'.must_match match_me
      '*!*@*'.must_match match_me
      '?*'.must_match match_me
      'someNick?!*@*'.wont_match match_me
      '*b*!*@*'.wont_match match_me
      '*q*'.wont_match match_me
    end
    
    it "matches against regexs" do
      /\Asome/.must_match match_me
      /stuffy@bri/.must_match match_me
      /\AsomeNick.!/.wont_match match_me
      /.*b.*!.*@.*/.wont_match match_me
      /q/.wont_match match_me
    end

    it "matches against matchers" do
      Ircbgb::WildcardMatcher.new('*o*!*stuffy@*i*.?o.u?').must_match match_me
      Ircbgb::WildcardMatcher.new('someNick?!*@*').wont_match match_me
    end
  end
end

