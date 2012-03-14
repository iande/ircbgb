module Ircbgb
  module Behaviors
    def self.included klass
      puts "Including #{self} in #{klass}"
      # Include behavior modules
      klass.__send__ :include, ProvidesCommands
      klass.__send__ :include, NegotiatesConnection
    end

    def initialize_behaviors
      register_connection_negotiation
    end
  end
end

require 'ircbgb/behaviors/provides_commands'
require 'ircbgb/behaviors/negotiates_connection'
