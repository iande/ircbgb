require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end

namespace :ragel do
  desc "Delete previously built files"
  task :clean do
    sh "rm lib/ircbgb/message_parser.rb"
  end

  desc "Generate parsers from Ragel definitions"
  task :parser do
    sh "ragel -R lib/ircbgb/message_parser.rl"
  end
end

desc "Ragel it!"
task :ragel => ['ragel:clean', 'ragel:parser']

desc "Generate a coverage report from tests with simplecov"
task :coverage do  
  ENV['SCOV'] = '1'
  Rake::Task['test'].invoke
end

task :default => [:test]
