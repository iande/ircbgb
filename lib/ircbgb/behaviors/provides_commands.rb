module Ircbgb::Behaviors
  module ProvidesCommands
    def do_pong echo
      write_command 'PONG', ":#{echo}"
    end

    def do_user username, realname
      write_command 'USER', "#{username} 0 * :#{realname}"
    end

    def do_nick nick
      write_command 'NICK', nick
    end

    def do_quit msg=nil
      msg = ":#{msg}" if msg
      write_command 'QUIT', msg
    end
  end
end
