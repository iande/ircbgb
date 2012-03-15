require File.expand_path('../../../spec_helper', __FILE__)

describe Ircbgb::Events::CallbackChain do
  let(:chain) { Ircbgb::Events::CallbackChain.new }

  it "adds to the chain" do
    chain << proc { }
    chain.wont_be :empty?
  end

  it "does not deadlock when adding to the chain will running" do
    called = false
    cb2 = proc { called = true }
    chain << proc { chain << cb2 }
    chain.call
    chain.call
    called.must_equal true
  end

  it "stops running the chain if a callback returns false" do
    called = [ false, false, false, false ]
    chain << proc { called[0] = true; nil } << proc { called[1] = true; false }
    chain << proc { called[2] = true } << proc { called[3] = true }
    chain.call
    called.must_equal [true, true, false, false]
  end
end
