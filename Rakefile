$LOAD_PATH.unshift './lib'

require 'rake/testtask'
Rake::TestTask.new(:test)

require 'bundler'
Bundler::GemHelper.install_tasks

require 'jsontrim'

task :default => [:test]
