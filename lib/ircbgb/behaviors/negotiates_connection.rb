module Ircbgb::Behaviors
  module NegotiatesConnection
    # TODO: even though we expect these modules
    # to be tightly coupled to Client, do we really
    # want to modify instance variables in them?

  private
    def initialize_negotiates_connection
      on_ping do |(pong, _)|
        do_pong pong
        @c_state = :connected if connecting?
      end

      on_433 do |pars|
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
