module Ircbgb
  class Message
    attr_reader :source, :arguments, :command, :params

    def initialize src, cmd, params
      @source = src
      @command = cmd.upcase
      @params = params
    end

    def numeric?
      # According to RFC 1459, this is strictly \A\d\d\d\Z, but we'll
      # allow a little flexibility
      !!(@command =~ /\A\d+\Z/)
    end
  end
end
