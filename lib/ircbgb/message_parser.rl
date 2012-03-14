# RFC 1459 Message Parser to be processed by Ragel
%%{
  machine irc_message_parser;

  action start_parser { eof = pe }
  action clear_command { cmd = '' }
  action clear_server { server = '' }
  action clear_rest { rest = '' }
  action clear_param { param = '' }
  action clear_user_mask { user_mask = '' }
  action append_user_mask { user_mask << data[p] }
  action append_server { server << data[p] }
  action append_param { param << data[p] }
  action append_params { params << param }
  action append_rest { rest << data[p] }
  action append_command { cmd << data[p] }
  action make_source_user {
    source = ::Ircbgb::User.parse(user_mask)
  }
  action make_source_server {
    source = ::Ircbgb::Server.new(server)
  }
  action show_me {
    puts "Currently parsing data[#{p}/#{data.length}]: '#{data[p]}'"
  }
  action message_error {
    raise ::Ircbgb::MessageFormatError, "invalid form #{data.inspect} at #{p} '#{data[p]}'"
  }

  sspace = ' ';
  crlf = '\r\n';
  whites = sspace | '\0' | '\r' | '\n';
  nospcrlfcl = any - whites - ':';
  nonwhite = any - whites;
  userchar = any - '@' - whites;
  ip4addr = digit{1,3} '.' digit{1,3} '.' digit{1,3} '.' digit{1,3};
  ip6addr = (xdigit+ (':' xdigit+){7})
            | ('0:0:0:0:0:' ('0' | [fF]{4}) ':' ip4addr);
  hostaddr = ip4addr | ip6addr;
  shortname = (alpha | digit) (alpha | digit | '-')* (alpha | digit)*;
  hostname = shortname ('.' shortname)*;
  host = hostname | hostaddr;
  user = userchar+;
  nick_special = '[' | ']' | '\\' | '`' | '_' | '^' | '{' | '|' | '}';
  nick = (alpha | nick_special) (alpha | digit | nick_special | '-')*;
  servername = hostname >clear_server $append_server %make_source_server;
  nick_mask = (nick ('!' user ('@' host)?)?) >clear_user_mask $append_user_mask %make_source_user;

  prefix = servername | nick_mask;
  command = (alpha+ | digit+) >clear_command @append_command;
  middle = (nospcrlfcl (':' | nospcrlfcl)*) >clear_param @append_param %append_params;
  trailing = ((nospcrlfcl | ' ' | ':')*) >clear_rest @append_rest;
  params = ((sspace+ middle){0,14} (sspace+ ':' trailing)?);

  message = (':' prefix sspace+)? command params? crlf;

  main := message >start_parser $err(message_error);
}%%

module Ircbgb
  class MessageParser

    %% write data;

    def self.parse str
      data = str
      server = ''
      user_mask = ''
      para = ''
      rest = ''
      params = []
      source = nil
      cmd = ''

      %% write init;
      %% write exec;

      params << rest unless rest.empty?

      ::Ircbgb::Message.new source, cmd, params
    end
  end
end

