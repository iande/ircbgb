module Ircbgb::Messages
  define :privmsg do
    target 0
    text 1
    targets { target.split(',') }
  end

  define :notice do
    target 0
    text 1
    targets { target.split(',') }
  end

  define :ctcp_request, :privmsg do
    match { |cmd, params, src|
      # Not even going to bother with embedded CTCP messages because
      # they don't have much support in common IRC clients
      params[1] =~ /\A\001.*\001\Z/
    }
    # Redefine text
    text { super()[1..-2] }
    request { text.split(' ').first }
  end

  define :ctcp_response, :notice do
    match { |cmd, params, src|
      params[1] =~ /\A\001.*\001\Z/
    }
    # Redefine text
    text { super()[1..-2] }
    response { text.split(' ').first }
  end

  define :join do
    channel { params[0] }
  end

  define :part do
    channel { params[0] }
    message { params[1] || '' }
  end

  define :kick do
    channel { params[0] }
    kicked { params[1] }
    message { params[2] || '' }
  end
end

