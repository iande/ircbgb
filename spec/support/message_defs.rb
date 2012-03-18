# A helper to wrap message definitions so we can remove
# them when we're done with the test.

module MessageDefs
  def defined_messages
    @defined_messages ||= []
  end

  def def_msg msg, par=nil, &block
    m_name = msg.to_s.split('_').map { |s| s.capitalize }.join('')
    p_name = par && par.to_s.split('_').map { |s| s.capitalize }.join('')
    defined_messages << [m_name, p_name]
    Ircbgb::Messages.define msg, par, &block
  end

  def reset_messages
    defined_messages.each do |m_name, p_name|
      if Ircbgb::Messages.const_defined?(m_name)
        msg = Ircbgb::Messages.const_get m_name
        rm_klass = if p_name
                     Ircbgb::Messages.const_defined?(p_name) &&
                       Ircbgb::Messages.const_get(p_name)
                   end
        rm_klass ||= Ircbgb::Message
        rm_klass.messages.delete_if { |sub| sub == msg }
        Ircbgb::Messages.__send__ :remove_const, m_name
      end
    end
  end
end
