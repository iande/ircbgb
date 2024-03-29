require File.expand_path('../../spec_helper', __FILE__)

describe Ircbgb::WildcardMatcher do
  def matcher str; Ircbgb::WildcardMatcher.new str; end

  it "treats ? as any single character (/./)" do
    match = matcher('?lAm?')
    'flame'.must_match match
    'bLAMe'.must_match match
    'lLaMa'.must_match match
    'claMer'.wont_match match
    'lam'.wont_match match
    'filame'.wont_match match
    'filament'.wont_match match
  end

  it "treats * as 0 or more characters (/.*/)" do
    match = matcher('*laM*')
    'lam'.must_match match
    'LaMabcdefghijklmnopqrstuvwxyz1234567890[]{}()!@#$%^&*'.must_match match
    'abcdefghijklmnopqrstuvwxyz1234567890[]{}()!@#$%^&*lAM'.must_match match
    'abcdefghijklmnopqrsLAMtuvwxyz1234567890[]{}()!@#$%^&*'.must_match match
    'flMa'.wont_match match
  end

  it "performs a case-insensitive match when there are no wildcards" do
    match = matcher('wHAm')
    'wham'.must_match match
    'WHAM'.must_match match
    'Wham'.must_match match
    'wHAmy'.wont_match match
    'efwHAm'.wont_match match
  end
end
