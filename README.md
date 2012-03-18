# Ircbgb

An IRC client library.

## Installing

Install it through rubygems,

    gem install ircbgb

or whatever, by now you know the drill.

## Purpose

To refresh my knowledge of RFC 1459 (et al) and to provide the first concrete
use case for [io_unblock](https://github.com/iande/io_unblock).

## Usage

### Start a Client

    client = Ircbgb::Client.new do |c|
      c.servers = [ 'irc://irc.freenode.net' ]
      c.nicks = [ 'nick1', 'nick2', 'nick3' ]
      c.username = 'user1'
      c.realname = 'I am a test client'
    end

    client.connect

This will open a socket to `irc.freenode.net` on port 6667 (by default) and
send the required `USER`, `NICK` and `PONG` commands to establish a connection.
The `io_unblock` library handles IO through a separate thread, as a result
there is no guarantee that the client is actually connected immediately after
`client.connect` is executed.


### Respond to events

    client.received :privmsg do |msg, me|
      # `me` == `client`
      $stdout.puts "<#{msg.source.nick}/#{msg.target}> #{msg.text}"
    end

    client.sent :privmsg do |msg, me|
      $stdout.puts "#{msg.target}> #{msg.text}"
    end

### Defining custom messages

    Ircbgb::Messages.define :privmsg do
      target 0
      text 1
      targets { target.split(',') }
    end

    Ircbgb::Messages.define :ctcp_request, :privmsg do
      match { |cmd, params, src|
        params[1] =~ /\A\001.*\001\Z/
      }

      request { text[1..-2] }
      ctcp_command { request.split(' ').first }
    end

With those definitions in place, if the IRC server sent the following
message:

    some_dude!dude@my.host.name PRIVMSG #stuff :Testing is fun!

Ircbgb would parse it into an instance of the `Privmsg` class we just
defined:

    a_msg.target  #=> "#stuff"
    a_msg.text    #=> "Testing is fun!"
    a_msg.params  #=> ["#stuf", "Testing is fun!"]
    a_msg.command #=> "PRIVMSG"
    a_msg.source  #=> Ircbgb::User

The `params`, `command`, and `source` attributes come from `Ircbgb::Message`,
which all defined messages inherit from. Our custom defined messages can
do even more!

If you sent the following message:

    PRIVMSG some_dude :\001VERSION\001

Ircbgb would parse it into an instance of the `CtcpRequest` class. The
parser resolves the string to a class by first examining the command, PRIVMSG,
in this case. It finds a `Privmsg` class, so now it gives subclasses of
`Privmsg` a chance to claim ownership of the message. As it happens,
`CtcpRequest` is a subclass of `Privmsg` because we gave `:privmsg` as the
second parameter to `Ircbgb::Messages.define`. The parser then invokes
the `match` block with the appropriate parameters, in this case "PRIVMSG",
"\001VERSION\001" and `nil` as the client itself is the source. The match
block detects the surrounding "\001" characters, and returns true, thus
a `CtcpRequest` is born (instead of a `Privmsg` or generic `Message` instance.)

Message definitions can leverage all kinds of neat stuff. I'll write more
on that later, in the mean time have a look at specs/ircbgb/messages_spec.rb


### Event shortcomings

The implementation is not quite what I want yet.

Currently, we have:


    client.received(:privmsg) { ... }

which is equivalent to

    client.received('PRIVMSG') { ... }

However,

    client.received(:ctcp_request) { ... }

will never get triggered, because Ircbgb triggers based solely on the command
name at the moment. Here's an example of what I ultimately want:


    client.define(:no_such_nickname, :numeric => 401)

    client.received(401) { ... }

    client.received(:no_such_nickname) { ... }

I think the way to handle this is to match against the command when a string
or fixnum is given to the event binding helpers (`sending`, `sent`,
`receiving`, `received`), and filter by class name when a symbol is given.
Further, I need to implement the ability to base a message definition off of a
numeric command.

I also want to change how callback chains can be stopped. At the moment, if
a callback returns `false`, no further processing on the chain is performed;
however, the `:all` chain still gets executed. Returning `false` isn't good
enough for me. I would rather have a couple explicit methods, like
`prevent_default!` and `halt!` where `prevent_default!` stops the default chain
from being executed, and `halt!` stops any further processing in the current
chain. If we wrap the callback evaluation within a kind of `CallbackEvent`
instance, we can provide these two methods, as well as some other goodies.
