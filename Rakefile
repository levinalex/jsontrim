$LOAD_PATH.unshift './lib'

require 'bundler'
Bundler::GemHelper.install_tasks

require 'jsontrim'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << "test"
end

task :default => [:test]
