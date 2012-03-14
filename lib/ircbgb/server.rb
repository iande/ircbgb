module Ircbgb
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
