module Ircbgb
  class Client
    include Behaviors
    CRLF = "\r\n".freeze

    attr_reader :nicks, :servers
    attr_accessor :realname, :username

    # Can be initialized with a block
    def initialize
      @servers = []
      @nicks = []
      @realname = ''
      @username = ''
      @c_state = :connecting
      @callbacks = {}
      @read_buffer = ''
      yield self if block_given?
      initialize_behaviors
    end

    def connecting?
      @c_state = :connecting
    end

    def connected?
      @c_state == :connected
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
      uri = uris.first
      @stream = IoUnblock::TcpSocket.new(uri.host, uri.port, {
        started: lambda { |st| negotiate_connection },
        read: lambda { |str| parse_message str }
      })
      @stream.start
      Thread.pass until @stream.running?
      self
    end

    def stop
      @stream && @stream.stop
      @stream = nil
      self
    end

    def bind ev, block, opts=nil
      @callbacks[ev] ||= []
      @callbacks[ev] << block
      self
    end

    def trigger ev, msg
      cbs = @callbacks[ev.downcase]
      if cbs
        cbs.each do |cb|
          cb.call(msg.params, msg)
        end
      end
      self
    end

  private
    def write_command cmd, args=nil
      rest = args.nil? ? '' : " #{args}"
      @stream.write "#{cmd.upcase}#{rest}#{CRLF}"
    end

    def parse_message str
      @read_buffer << str
      while pos = @read_buffer.index(CRLF)
        msg_str = @read_buffer[0..(pos+1)]
        @read_buffer = @read_buffer[(pos+2)..-1]
        msg = MessageParser.parse(msg_str)
        trigger msg.command, msg
      end
    end

    def method_missing meth, *args, &block
      if meth[0..2] == 'on_'
        bind meth[3..-1].downcase, block, args
      else
        super
      end
    end
  end
end
