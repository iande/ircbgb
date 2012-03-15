module Ircbgb::Events
  class Handler
    attr_reader :running
    alias :running? :running

    def initialize client
      @client = client
      @callbacks = Hash.new { |h, k| h[k] = {} }
      @worker = nil
      @dispatch = ::Queue.new
      @running = false
      @s_lock = Mutex.new
      @c_lock = Mutex.new
    end

    def start
      @s_lock.synchronize do
        raise IrcbgbError, 'already running' if @running
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
    end

    def empty?
      @dispatch.empty?
    end

    def alive?
      @worker && @worker.alive?
    end

    def once group, *matchers, &cb
      bind group, *(matchers + [{:times => 1}]), &cb
    end

    def bind group, *commands, &cb
      opts = commands.last.is_a?(Hash) ? commands.pop : {}
      @c_lock.synchronize do
        if commands.empty?
          @callbacks[group][:all] ||= []
          @callbacks[group][:all] << Callback.new(cb, opts)
        else
          commands.each do |cmd|
            cmd = cmd.to_s.upcase
            @callbacks[group][cmd] ||= []
            @callbacks[group][cmd] << Callback.new(cb, opts)
          end
        end
      end
      self
    end

    def trigger group, msg
      return unless running?
      @dispatch << [group, msg]
      self
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
      return if msg.nil?
      cmd = msg.command.upcase
      cbs = nil
      all = nil
      @c_lock.synchronize do
        cbs = @callbacks[group].key?(cmd) && @callbacks[group][cmd].dup
        all = @callbacks[group].key?(:all) && @callbacks[group][:all].dup
      end
      if cbs
        cbs.each do |cb|
          break if cb.call(msg, @client) == false
        end
      end
      if all
        all.each do |cb|
          break if cb.call(msg, @client) == false
        end
      end
    end

    def work_off_events
      _trigger *@dispatch.shift
    end
  end
end
