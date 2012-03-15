module Ircbgb::Events
  class Callback
    def initialize cb, opts
      @callback = cb
      @times = opts.fetch(:times) { false }
    end

    def call msg, client
      unless exhausted?
        @times -= 1 if @times
        @callback.call msg, client
      end
    end

    def exhausted?
      @times && @times <= 0
    end
  end

end
