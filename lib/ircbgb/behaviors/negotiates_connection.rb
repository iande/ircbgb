module Ircbgb::Behaviors
  module NegotiatesConnection
    # TODO: even though we expect these modules
    # to be tightly coupled to Client, do we really
    # want to modify instance variables in them?

  private
    def initialize_negotiates_connection
      received 'ping' do |msg|
        do_pong msg.params.first
        @c_state = :connected if connecting?
      end

      received 433 do
        if connecting?
          next_nick = next_nickname
          if next_nick
            do_nick next_nick
          else
            do_quit
          end
        end
      end
    end

    def negotiate_connection
      do_user self.username, self.realname
      do_nick next_nickname
    end

    def next_nickname
      @next_nick_idx ||= 0
      nicks[@next_nick_idx].tap do
        @next_nick_idx += 1
      end
    end
  end
end
