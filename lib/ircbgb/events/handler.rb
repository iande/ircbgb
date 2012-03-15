module Ircbgb::Events
  class EventError < Ircbgb::IrcbgbError; end

  class Handler
    attr_reader :running
    alias :running? :running

    def initialize client
      @client = client
      @callbacks = {
        :sending => CallbackGroup.new,
        :sent => CallbackGroup.new,
        :receiving => CallbackGroup.new,
        :received => CallbackGroup.new
      }
      @worker = nil
      @dispatch = ::Queue.new
      @running = false
      @s_lock = Mutex.new
    end

    def start
      @s_lock.synchronize do
        raise EventError, 'already running' if @running
        @running = true
        @worker = Thread.new do
          work_off_events while running?
          work_off_events until empty?
        end
      end
    end

    def stop
      if @worker == Thread.current
        stop_inside
      else
        stop_outside
      end
      self
    end

    def empty?
      @dispatch.empty?
    end

    def alive?
      @worker && @worker.alive?
    end

    [:sending, :sent, :receiving, :received].each do |group|
      class_eval <<-EOS
        def #{group} *matchers, &cb
          bind #{group.inspect}, *matchers, &cb
        end

        def #{group}_once *matchers, &cb
          once #{group.inspect}, *matchers, &cb
        end
        
        def trigger_#{group} msg
          trigger #{group.inspect}, msg
        end
      EOS
    end

  private
    def bind group, *cmds, &block
      opts = cmds.last.is_a?(Hash) ? cmds.pop : {}
      cb = Callback.new(block, opts)
      cmds = cmds.empty? ? [:all] : cmds.map { |c| c.to_s.upcase }
      @callbacks[group].add_all cmds, cb
      self
    end

    def once group, *matchers, &cb
      bind group, *(matchers + [{:times => 1}]), &cb
    end

    def trigger group, msg
      return unless running?
      @dispatch << [group, msg]
      self
    end
    def stop_inside
      # We don't need one last event here, because we're executing
      # within an event.
      @running = false
    end

    def stop_outside
      @s_lock.synchronize do
        if @running
          @running = false
          # We need one last event to ensure the queue unblocks
          @dispatch << [:exit, nil]
          @worker.join
        end
      end
    end

    def _trigger group, msg
      # A bit hackey
      return if msg.nil?
      @callbacks[group].call msg.command.upcase, msg, @client
      @callbacks[group].call :all, msg, @client
    end

    def work_off_events
      _trigger *@dispatch.shift
    end
  end
end
