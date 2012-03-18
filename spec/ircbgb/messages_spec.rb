require File.expand_path('../../spec_helper', __FILE__)

describe Ircbgb::Messages do
  include MessageDefs
  before do
    @mod = Ircbgb::Messages
  end

  after do
    reset_messages
  end

  describe "defining messages" do
    it "creates a message class" do
      @mod.const_defined?('TestMessage').must_equal false
      def_msg :test_message
      @mod.const_defined?('TestMessage').must_equal true
    end

    it "does not clobber existing classes" do
      def_msg :test_message
      klass = @mod.const_get('TestMessage')
      def_msg :test_message
      @mod.const_get('TestMessage').must_equal klass
    end

    it "creates subclasses of Message" do
      def_msg :testing
      (Ircbgb::Messages::Testing < Ircbgb::Message).must_equal true
    end

    it "matches on command by default" do
      def_msg :testing
      Ircbgb::Messages::Testing.matches?('PRIVMSG', [], nil).must_equal false
      Ircbgb::Messages::Testing.matches?('TESTING', [], nil).must_equal true
    end

    it "allows a custom matcher to be defined" do
      def_msg :testing do
        match { |cmd, params, src|
          cmd == 'W00T' && params.first == 'X' && src == 'L'
        }
      end
      Ircbgb::Messages::Testing.matches?('TESTING', [], 'L').must_equal false
      Ircbgb::Messages::Testing.matches?('W00T', ['X'], 'V').must_equal false
      Ircbgb::Messages::Testing.matches?('W00T', ['X', 'Y'], 'L').must_equal true
    end


    it "allows custom attributes to be defined" do
      def_msg :testing do
        let(:shorter) { "#{params.first}..#{params.last}" }
      end
      msg = Ircbgb::Messages::Testing.new('', ['hello', 'there', 'world'], nil)
      msg.shorter.must_equal "hello..world"
    end

    it "gives precedence to later attribute definitions" do
      def_msg :testing do
        let(:shorter) { "#{params.first}..#{params.last}" }
        let(:shorter) { "Short!" }
        let(:shorter) { "#{params.first[0..2]}..#{params.last[0..2]}" }
      end
      msg = Ircbgb::Messages::Testing.new('', ['hello', 'world'], nil)
      msg.shorter.must_equal 'hel..wor'
    end

    it "allows previous attribute definitions to be fetched through super()" do
      def_msg :testing do
        let(:shorter) { [params.first, params.last] }
        let(:shorter) { super().map { |s| s[0..2] } }
        let(:shorter) { super().join('..') }
      end
      msg = Ircbgb::Messages::Testing.new('', ['hello', 'world'], nil)
      msg.shorter.must_equal 'hel..wor'
    end

    it "defines subclassed messages" do
      def_msg :testing
      def_msg :sub_testing, :testing
      (Ircbgb::Messages::SubTesting < Ircbgb::Messages::Testing).must_equal true
    end

    it "respects class inheritence" do
      def_msg :testing do
        let(:first) { params.first }
        let(:last) { params.last }
      end
      def_msg :sub_testing, :testing do
        let(:first) { "FIRST: #{super()}" }
        let(:my_last) { "AND: #{last}" }
      end
      msg = Ircbgb::Messages::SubTesting.new('', ['hello', 'world'], nil)
      msg.first.must_equal 'FIRST: hello'
      msg.last.must_equal 'world'
      msg.my_last.must_equal 'AND: world'
    end

    it "gives us some sugar" do
      def_msg :testing do
        first { params.first }
        last { params.last }
      end
      msg = Ircbgb::Messages::Testing.new('', ['hello', 'cruel', 'world'], nil)
      msg.first.must_equal 'hello'
      msg.last.must_equal 'world'
    end

    it "gives us some params sugar" do
      def_msg :testing do
        foo 0
        bar 1, 3
        buz(2..-1) { |sel| sel.join('--') + "/#{command}" }
      end
      msg = Ircbgb::Messages::Testing.new('CMD', ['a','b','c','d','e'], nil)
      msg.foo.must_equal 'a'
      msg.bar.must_equal ['b', 'c', 'd']
      msg.buz.must_equal 'c--d--e/CMD'
    end

    it "complains when our sugar lacks meaning" do
      lambda do
        def_msg :testing do
          foo
        end
      end.must_raise ::NameError

      lambda do
        def_msg :testing do
          foo()
        end
      end.must_raise ::NoMethodError
    end
  end

  describe "message instance generation" do
    it "resolves to Message when no match is found" do
      def_msg :type1
      def_msg :type2
      @mod.generate('OTHER', [], nil).class.must_equal Ircbgb::Message
    end

    it "resolves to a defined type by name" do
      def_msg :type1
      def_msg :type2
      @mod.generate('TYPE1', [], nil).class.must_equal Ircbgb::Messages::Type1
    end

    it "resolves with a custom matcher" do
      def_msg :type1 do
        match { |c,p,s| c == 'W00T' }
      end
      @mod.generate('TYPE1', [], nil).class.must_equal Ircbgb::Message
      @mod.generate('W00T', [], nil).class.must_equal Ircbgb::Messages::Type1
    end

    it "resolves to a subclass only if the parent class matches" do
      def_msg :type1
      def_msg :type2, :type1 do
        match { |c,p,s| p.first == 'x' }
      end
      def_msg :type3, :type2 do
        match { |c,p,s| p.last == 'y' }
      end
      @mod.generate('TYPE1', [], nil).class.must_equal Ircbgb::Messages::Type1
      @mod.generate('TYPE2', ['x'], nil).class.must_equal Ircbgb::Message
      @mod.generate('TYPE3', ['x', 'y'], nil).class.must_equal Ircbgb::Message
      @mod.generate('TYPE1', ['x'], nil).class.must_equal Ircbgb::Messages::Type2
      @mod.generate('TYPE1', ['x', 'y'], nil).class.must_equal Ircbgb::Messages::Type3
    end

    it "resolves properly when the base message uses a custom matcher" do
      def_msg :type1 do
        match { |c,p,s| c == 'W00T' && p.first.upcase == p.first }
      end
      def_msg :type2, :type1 do
        match { |c,p,s| p.first == 'X' }
      end
      def_msg :type3, :type2 do
        match { |c,p,s| p.last == 'y' }
      end
      @mod.generate('TYPE1', ['X', 'y'], nil).class.must_equal Ircbgb::Message
      @mod.generate('W00T', ['V', 'y'], nil).class.must_equal Ircbgb::Messages::Type1
      @mod.generate('W00T', ['X', 'k'], nil).class.must_equal Ircbgb::Messages::Type2
      @mod.generate('W00T', ['X', 'y'], nil).class.must_equal Ircbgb::Messages::Type3
    end
  end
end

