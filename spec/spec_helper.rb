if ENV['SCOV']
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end
end

begin
  require 'minitest/autorun'
  require 'minitest/emoji'
rescue LoadError
end

Dir[File.expand_path('../support/*.rb', __FILE__)].each do |r|
  require r
end

require 'ircbgb'
