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
      @callbacks = {
        :sent => {},
        :sending => {},
        :received => {},
        :receiving => {}
      }
      @read_buffer = ''
      yield self if block_given?
      initialize_behaviors
      @message_written = proc do |l, b, msg|
        trigger_sent msg
      end
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
        :started => lambda { |st| negotiate_connection },
        :read => lambda { |str| parse_message str }
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

    def sending cmd, &block
      bind :sending, cmd, block
    end

    def sent cmd, &block
      bind :sent, cmd, block
    end

    def receiving cmd, &block
      bind :receiving, cmd, block
    end

    def received cmd, &block
      bind :received, cmd, block
    end

  private
    def bind at, cmd, cb
      ev = cmd.to_s.downcase
      @callbacks[at][ev] ||= []
      @callbacks[at][ev] << cb
      self
    end

    def trigger at, msg
      ev = msg.command.downcase
      if cbs = @callbacks[at][ev]
        cbs.each do |cb|
          cb.call self, msg.params, msg
        end
      end
      self
    end

    def trigger_sending msg
      trigger :sending, msg
    end

    def trigger_sent msg
      trigger :sent, msg
    end

    def trigger_receiving msg
      trigger :receiving, msg
    end

    def trigger_received msg
      trigger :received, msg
    end

    def write_command cmd, args=nil
      rest = args.nil? ? '' : " #{args}"
      msg_str = "#{cmd.upcase}#{rest}#{CRLF}"
      msg = MessageParser.parse(msg_str)
      @stream.write(msg_str, msg, &@message_written)
      trigger_sending msg 
    end

    def parse_message str
      @read_buffer << str
      while pos = @read_buffer.index(CRLF)
        msg_str = @read_buffer[0..(pos+1)]
        @read_buffer = @read_buffer[(pos+2)..-1]
        msg = MessageParser.parse(msg_str)
        trigger_receiving msg
        trigger_received msg
      end
    end
  end
end
