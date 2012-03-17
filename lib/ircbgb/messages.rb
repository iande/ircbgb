module Ircbgb
  module Messages
    class << self
      def define name, parent=nil, &block
        message_class(name, parent).tap do |klass| 
          MessageBuilder.new(&block).apply_definition(klass)
        end
      end

      def generate cmd, params, src
        up_the_chain(cmd, params, src).new(cmd, params, src)
      end

    private
      def up_the_chain cmd, params, src, klass=Message
        sub = klass.messages.detect { |k| k.matches?(cmd, params, src) }
        sub && up_the_chain(cmd, params, src, sub) || klass
      end

      def message_class name, parent
        klass_name = translate_name(name)
        if const_defined? klass_name
          const_get klass_name
        else
          parent = resolve_parent(parent)
          Class.new(parent).tap do |k|
            k.set_command! klass_name.upcase
            const_set klass_name, k
          end
        end
      end

      def resolve_parent parent
        case parent
        when Class
          parent
        when '', nil
          Ircbgb::Message
        else
          const_get translate_name(parent)
        end
      end

      def translate_name name
        name.to_s.split('_').map { |s| s.capitalize }.join('')
      end
    end
  end

  # @api private
  class MessageBuilder
    def initialize &block
      @matcher = nil
      @attribs = {}
      instance_eval(&block) if block
    end

    def match &block
      @matcher = block
    end

    def let name, &block
      mod = Module.new
      mod.__send__(:define_method, name, &block)
      if @attribs.key? name
        mod.__send__(:include, @attribs[name])
      end
      @attribs[name] = mod
    end

    def apply_definition klass
      meta = class << klass; self; end
      meta.__send__(:define_method, :matches?, &@matcher) if @matcher
      @attribs.each do |name, mod|
        klass.__send__(:include, mod)
      end
      self
    end

    def method_missing meth, *args, &block
      if args.size > 0
        # Set the base to return some parameters
        let(meth) { params[*args] }
        # If we also have a block, use our inheritance chain
        # and instance_exec to let `block` transform the params while
        # still having access to the instance itself
        let(meth) { instance_exec(super(), &block) } if block
      elsif block
        let(meth, &block)
      else
        super
      end
    end
  end

  class Message
    attr_reader :source, :arguments, :command, :params

    def initialize cmd, params, src
      @source = src
      @command = cmd.upcase
      @params = params
    end

    def numeric?
      # According to RFC 1459, this is strictly \A\d\d\d\Z, but we'll
      # allow a little flexibility
      !!(@command =~ /\A\d+\Z/)
    end

    def to_s
      source_prefix + @command + params_string
    end

    class << self
      attr_reader :command

      def set_command! cmd
        @command ||= cmd
      end

      def matches? cmd, params, src
        @command == cmd
      end

      def messages
        @messages ||= []
      end

      def inherited base
        messages << base
      end
    end

  private
    def source_prefix
      @source ? ":#{@source.to_s} " : ''
    end

    def params_string
      return '' if @params.empty?
      param_s = ''
      @params.each_with_index do |p, i|
        param_s << ' '
        if p.include?(' ')
          param_s << ":#{@params[i..-1].join(' ')}"
          break
        else
          param_s << p
        end
      end
      param_s
    end
  end
end

require 'ircbgb/messages/common'
