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

  class CallbackChain
    def initialize
      @chain = []
      @c_lock = Mutex.new
    end

    def << cb
      synched { @chain << cb }
      self
    end

    def empty?
      @chain.empty?
    end

    def call *args
      tmp_chain = synched { @chain.dup }
      tmp_chain.each do |cb|
        break if cb.call(*args) == false
      end
    end

  private
    def synched &block
      @c_lock.synchronize(&block)
    end
  end

  class CallbackGroup
    def initialize
      @chains = {}
      @g_lock = Mutex.new
    end
    
    def call name, *args
      chain = synched { @chains[name] }
      chain.call(*args) if chain
      self
    end

    def add name, cb
      synched { @chains[name] ||= CallbackChain.new }
      @chains[name] << cb
      self
    end

    def add_all names, cb
      names.each do |name|
        add name, cb
      end
    end

  private
    def synched &block
      @g_lock.synchronize(&block)
    end
  end
end
