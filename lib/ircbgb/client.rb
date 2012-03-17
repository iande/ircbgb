module Ircbgb
  class Client
    extend Forwardable
    include Behaviors
    CRLF = "\r\n".freeze

    attr_reader :nicks, :servers
    attr_accessor :realname, :username
    def_delegators :@events, :sending, :sent, :receiving, :received,
      :sending_once, :sent_once, :receiving_once, :received_once

    # Can be initialized with a block
    def initialize
      @servers = []
      @nicks = []
      @realname = ''
      @username = ''
      @c_state = :connecting
      @read_buffer = ''
      @events = Events::Handler.new self
      @events.start
      yield self if block_given?
      initialize_behaviors
      @message_written = proc do |l, b, msg|
        @events.trigger_sent msg
      end
    end

    def connecting?
      @c_state == :connecting
    end

    def connected?
      @c_state == :connected
    end

    def running?
      connecting? || connected?
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
      @c_state = :connecting
      uri = uris.first
      @stream = IoUnblock::TcpSocket.new(uri.host, uri.port, {
        :started => lambda { |st| negotiate_connection },
        :read => lambda { |str| parse_message str },
        :stopped => lambda { |st| stop },
        :failed => lambda { |ex| stop }
      })
      @stream.start
      Thread.pass until @stream.running?
      self
    end

    def stop
      @events.stop
      @stream && @stream.stop
      @c_state = :stopped
      self
    end

  private
    def write_command cmd, args=nil
      rest = args.nil? ? '' : " #{args}"
      msg_str = "#{cmd.upcase}#{rest}#{CRLF}"
      msg = MessageParser.parse(msg_str)
      @stream.write(msg_str, msg, &@message_written)
      @events.trigger_sending msg 
    end

    def parse_message str
      @read_buffer << str
      while pos = @read_buffer.index(CRLF)
        msg_str = @read_buffer[0..(pos+1)]
        @read_buffer = @read_buffer[(pos+2)..-1]
        msg = MessageParser.parse(msg_str)
        @events.trigger_receiving msg
        @events.trigger_received msg
      end
    end
  end
end
