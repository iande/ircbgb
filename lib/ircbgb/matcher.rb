module Ircbgb
  class Matcher
    def initialize pattern
      escaped = Regexp.escape(pattern)
      regexed = escaped.gsub("\\*", '.*').gsub("\\?", '.')
      @pattern = Regexp.new("\\A#{regexed}\\Z", Regexp::IGNORECASE)
    end

    def =~ str
      str.to_s =~ @pattern
    end
  end
end
