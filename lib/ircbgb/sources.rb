module Ircbgb
  class User
    attr_reader :nick, :user, :host

    def initialize n, u, h
      @nick = n.empty? ? '*' : n
      @user = u.empty? ? '*' : u
      @host = h.empty? ? '*' : h
      @mask = "#{@nick}!#{@user}@#{@host}"
    end

    def to_s; @mask.dup; end

    def =~ other
      return WildcardMatcher.new(other) =~ @mask if String === other
      @mask =~ other
    end

    class << self
      def parse nick_mask
        case nick_mask
        when Ircbgb::User
          nick_mask
        when /\A([^!]+)!([^@]*)@(.*)\Z/ 
          new $1, $2, $3
        else
          new nick_mask, '', ''
        end
      end
    end
  end

  class Server
    attr_reader :host
    alias :user :host
    alias :nick :host

    def initialize h
      @host = h
    end

    def to_s; @host.dup; end
  end
end
