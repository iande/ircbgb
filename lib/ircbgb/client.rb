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
      sock = TCPSocket.new(uris.first.host, uris.first.port)
      @stream = IoUnblock::Stream.new(sock, {
        started: lambda { |_| register_user },
        read: lambda { |str| puts "Read: #{str}" },
        callback_failed: lambda { |ex, ev| $stdout.puts "Failure: #{ex}" }
      })
      @stream.start
      Thread.pass until @stream.running?
    end

    def stop
      @stream.stop
    end

  private
    def register_user
      @stream.write("USER #{username} x y :#{realname}\r\n") { |*_|
        @stream.write("NICK #{nicks.first}\r\n") { |*_|
          @connected = true
        }
      }
      # @connected = true
    end
  end
end
