require File.expand_path('../../../spec_helper', __FILE__)

describe Ircbgb::Events::Handler do
  let(:client) { :client }
  let(:source) { :source }
  let(:events) { Ircbgb::Events::Handler.new(client) }

  before do
    @th_abort = ::Thread.abort_on_exception
    ::Thread.abort_on_exception = true
  end

  after do
    ::Thread.abort_on_exception = @th_abort
  end

  def irc_msg cmd='CMD', params=[1, :a, 32]
    Ircbgb::Message.new(source, cmd, params)
  end

  describe "threading" do
    it "raises an exception if started twice" do
      events.start
      lambda {
        events.start
      }.must_raise Ircbgb::Events::EventError
      events.stop
    end

    it "stops after all pending events have been dispatched" do
      events.start
      waiting = true
      events.receiving('CMD') do
        Thread.pass while waiting
      end
      10.times { events.trigger_receiving irc_msg }
      t = Thread.new { events.stop }
      waiting = false
      t.join
      events.must_be :empty?
    end

    it "does not queue events when its not running" do
      events.start
      events.trigger_receiving irc_msg
      events.stop
      events.must_be :empty?
      10.times { events.trigger_receiving irc_msg }
      events.must_be :empty?
    end

    it "can be stopped within an event" do
      events.start
      events.sending('CMD') do
        events.stop
      end
      events.trigger_sending(irc_msg)
      Thread.pass while events.alive?
      events.wont_be :running?
    end

    it "does not moan about being stopped repeatedly" do
      events.start
      events.stop
      10.times { events.stop }
      events.wont_be :running?
    end

    it "can trigger events within an event" do
      events.start
      triggered = false
      queued = false
      events.sent('CMD2') { triggered = true }
      events.sending('CMD1') { events.trigger_sent(irc_msg('CMD2')); queued = true }
      events.trigger_sending(irc_msg('CMD1'))
      # NOTE: This ensures that the event isn't dispatched as a result of `stop`
      Thread.pass until queued
      events.stop
      triggered.must_equal true
    end

    it "can bind events within an event" do
      events.start
      triggered = false
      queued = false
      events.sending('CMD1') do
        events.sent('CMD2') { triggered = true }
        queued = true
      end
      events.trigger_sending(irc_msg('CMD1'))
      events.trigger_sent(irc_msg('CMD2'))
      events.stop
      triggered.must_equal true
    end
  end

  describe "binding and trigger" do
    before do
      events.start
    end

    after do
    end

    it "binds a callback with a string" do
      cb_m, cb_c = nil, nil
      msg = irc_msg
      events.receiving('CMD') { |m, c| cb_m, cb_c = m, c}
      events.trigger_receiving(msg)
      events.trigger_receiving(irc_msg('NOT_CMD'))
      events.stop
      cb_m.must_equal msg
      cb_c.must_equal :client
    end

    it "binds a callback with a fixnum" do
      cb_m, cb_c = nil, nil
      msg = irc_msg('302')
      events.received(302) { |m, c| cb_c, cb_m = c, m }
      events.trigger_received(msg)
      events.trigger_received(irc_msg('404'))
      events.stop
      cb_m.must_equal msg
      cb_c.must_equal :client
    end

    it "binds to all events when no matcher is given" do
      msgs = []
      events.sending { |m, c| msgs << m.command }
      events.trigger_sending(irc_msg('CMD1'))
      events.trigger_sending(irc_msg('ANOTHER'))
      events.trigger_sending(irc_msg('302'))
      events.stop
      msgs.must_equal [ 'CMD1', 'ANOTHER', '302' ]
    end

    it "binds a callback to multiple matchers" do
      msgs = []
      events.sent('OMGG', 'PRIVMSG') { |m, c| msgs << m.command }
      events.trigger_sent(irc_msg('AMD'))
      events.trigger_sent(irc_msg('CMSG'))
      events.trigger_sent(irc_msg('PRIVMSG'))
      events.trigger_sent(irc_msg('OMGG'))
      events.trigger_sent(irc_msg('CM3'))
      events.stop
      msgs.must_equal [ 'PRIVMSG', 'OMGG' ]
    end

    it "calls all matching callbacks" do
      msgs1 = []
      msgs2 = []
      events.receiving('CMD') { |m, c| msgs1 << true }
      events.receiving('CMD') { |m, c| msgs2 << true }
      events.trigger_receiving(irc_msg)
      events.trigger_receiving(irc_msg)
      events.stop
      msgs1.must_equal [true, true]
      msgs2.must_equal [true, true]
    end

    it "binds a finite callback" do
      msgs1 = []
      msgs2 = []
      events.received('CMD') { |m, c| msgs1 << m.command }
      events.received('CMD', :times => 2) { |m, c| msgs2 << m.command }
      5.times { events.trigger_received(irc_msg) }
      events.stop
      msgs1.must_equal ['CMD', 'CMD', 'CMD', 'CMD', 'CMD']
      msgs2.must_equal ['CMD', 'CMD']
    end

    it "allows callbacks to halt further processing if they return false" do
      msgs1 = []
      msgs2 = []
      msgs3 = []
      events.sending('CMD') { |m, c| msgs1 << m.command; nil }
      events.sending('CMD') { |m, c| msgs2 << m.command; false }
      events.sending('CMD') { |m, c| msgs3 << m.command }
      3.times { events.trigger_sending(irc_msg) }
      events.stop
      msgs1.must_equal [ 'CMD', 'CMD', 'CMD' ]
      msgs2.must_equal [ 'CMD', 'CMD', 'CMD' ]
      msgs3.must_equal []
    end

    describe "helpers" do
      it "provides a sending method for binding to the :sending group" do
        msgs = []
        events.sending('X', 'Y', 'Z') { |m, c| msgs << m.command }
        events.trigger_sending irc_msg('Z')
        events.stop
        msgs.must_equal ['Z']
      end

      it "provides a sent method for binding to the :sending group" do
        msgs = []
        events.sent('X', 'Y', 'Z') { |m, c| msgs << m.command }
        events.trigger_sent irc_msg('Z')
        events.stop
        msgs.must_equal ['Z']
      end

      it "provides a receiving method for binding to the :sending group" do
        msgs = []
        events.receiving('X', 'Y', 'Z') { |m, c| msgs << m.command }
        events.trigger_receiving irc_msg('Z')
        events.stop
        msgs.must_equal ['Z']
      end

      it "provides a received method for binding to the :sending group" do
        msgs = []
        events.received('X', 'Y', 'Z') { |m, c| msgs << m.command }
        events.trigger_received irc_msg('Z')
        events.stop
        msgs.must_equal ['Z']
      end

      it "provides *_once variants for sending, sent, receiving, received" do
        msgs = {:sending => [], :sent => [], :receiving => [], :received => []}
        events.sending_once('X','Y','Z') { |m, c| msgs[:sending] << m.command }
        events.sent_once('X','Y','Z') { |m, c| msgs[:sent] << m.command }
        events.receiving_once('X','Y','Z') { |m, c| msgs[:receiving] << m.command }
        events.received_once('X','Y','Z') { |m, c| msgs[:received] << m.command }
        5.times do
          events.trigger_received irc_msg('Z')
          events.trigger_receiving irc_msg('X')
          events.trigger_sending irc_msg('Y')
          events.trigger_sent irc_msg('Z')
        end
        events.stop
        msgs[:sending].must_equal ['Y']
        msgs[:sent].must_equal ['Z']
        msgs[:receiving].must_equal ['X']
        msgs[:received].must_equal ['Z']
      end
    end
  end
end

