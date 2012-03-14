module Ircbgb
  class Client
    attr_reader :nicks, :servers, :connected
    attr_accessor :realname, :username
    alias :connected? :connected

    # Can be initialized with a block
    def initialize
      @servers = []
      @nicks = []
      @realname = ''
      @username = ''
      @connected = false
      yield self if block_given?
    end

    def nicks= nicks
      @nicks = Array(nicks)
    end

    def servers= servs
      @servers = Array(servs)
    end

    def uris
      @servers.map { |s|
        URI.parse(s).tap do |u|
          u.port ||= 6667
        end
      }
    end

    def start
    end

    def stop
    end
  end
end
