# Rather than using IoUnblock with a mock TCPSocket, we'll trust IoUnblock to
# test itself properly, and mock out IoUnblock::TcpSocket instead.
class UnblockedTcpSocket
  attr_reader :host, :port, :callbacks, :written

  def initialize
    @written = []
  end

  def init_with host, port, callbacks=nil
    @callbacks = callbacks || {}
    @writebacks = []
    @host = host
    @port = port
    @callbacks[:callback_failed] ||= lambda { |ex|
      warn "Default callback_failed handler: #{ex}"
    }
    self
  end

  def start; self; end
  def stop; self; end
  def running?; true; end

  def server_write_raw str
    @callbacks[:read] && @callbacks[:read].call(str)
  end

  def server_write cmd, max_len=nil
    server_write_raw ":#{@host} #{cmd}\r\n"
  end

  def write str, *cb_args, &cb
    if str[-2..-1] != "\r\n"
      raise "You forgot to CRLF your message"
    end
    @writebacks << [cb, str, cb_args] if cb
    @written << str[0..-3]
  end

  def trigger_start
    trigger_ev :started, :start
  end

  def trigger_loop
    trigger_ev :looped, self
  end

  def trigger_stop
    trigger_ev :stopped, :stop
  end

  def trigger_full_write_callbacks
    @writebacks.each do |cb, str, cb_args|
      cb.call str, str.size, *cb_args
    end
  end

  def trigger_ev ev, *args
    @callbacks[ev] && @callbacks[ev].call(*args)
  rescue Exception
    if ev != :callback_failed
      @callbacks[:callback_failed].call($!)
    else
      warn "Your callback failure callback is raising errors: #{$!}"
    end
  end
end
