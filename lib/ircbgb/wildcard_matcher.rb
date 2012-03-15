module Ircbgb
  class WildcardMatcher
    def initialize pattern
      # TODO: consider a possible optimization where we only use Regexps when
      # the pattern contains '*' or '?'
      escaped = Regexp.escape(pattern)
      regexed = escaped.gsub("\\*", '.*').gsub("\\?", '.')
      @pattern = Regexp.new("\\A#{regexed}\\Z", Regexp::IGNORECASE)
    end

    def =~ str
      str.to_s =~ @pattern
    end
  end
end
