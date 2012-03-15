require File.expand_path('../../../spec_helper', __FILE__)

describe Ircbgb::Events::CallbackGroup do
  let(:cb_group) { Ircbgb::Events::CallbackGroup.new }

  it "runs callbacks for a named chain" do
    called = [false, false]
    cb_group.add('name1', proc { called[0] = true })
    cb_group.add('name2', proc { called[1] = true })
    cb_group.call('name1', 1, 2, 3)
    called.must_equal [true, false]
  end

  it "does not deadlock when adding while running" do
    called = [0, 0, 0]
    cb_group.add('name1', proc {
      cb_group.add('name1', proc { called[1] += 1 })
      cb_group.add('name2', proc { called[2] += 1 })
      called[0] += 1
    })
    cb_group.call('name1', :a, :b, :c, :d)
    cb_group.call('name2', :a, :b, :c, :d)
    cb_group.call('name1', :a, :b, :c, :d)
    called.must_equal [2, 1, 1]
  end
end
