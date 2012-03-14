module Ircbgb
  module Behaviors
    def self.included klass
      # Include behavior modules
      klass.__send__ :include, ProvidesCommands
      klass.__send__ :include, NegotiatesConnection
    end

    def initialize_behaviors
      initialize_negotiates_connection
    end
  end
end

require 'ircbgb/behaviors/provides_commands'
require 'ircbgb/behaviors/negotiates_connection'
