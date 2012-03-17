module Ircbgb::Messages

  # I don't particularly want to define classes, seems like a lot of
  # unnecessary cruft for something that just adds some syntactic sugar to
  # parameters.
  
  define_message_type :privmsg do
    # selector { command == 'PRIVMSG' } default case if no selector is provided
    target { params.first || '' }
    targets { targets.split ',' }
    text { params.last }
  end

  define_message_type :notice do
    target { params.first || '' }
    targets { targets.split ',' }
    text { params.last }
  end

  # I'm not going to bother with embedded CTCP requests or quoting.
  # Apparently no one supports them anyway.
  define_message_type :ctcp_request do
     selector {
       command == 'PRIVMSG' && text =~ /\A\001.*\001\Z/
     }
     request { text.gsub("\001", '') }
  end

  define_message_type :ctcp_response do
     selector {
       command == 'NOTICE' && text =~ /\A\001.*\001\Z/
     }
     response { text.gsub("\001", '') }
  end
end
