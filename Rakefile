# Encoding: utf-8
require 'rake'
require 'rake/testtask'
require 'rake/packagetask'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
# require 'spree/testing_support/common_rake'

RSpec::Core::RakeTask.new

task :default => :spec

spec = eval(File.read('spree_alipay_forex_trade.gemspec'))

Gem::PackageTask.new(spec) do |p|
  p.gem_spec = spec
end


desc "Generates a dummy app for testing"
task :test_app do
  ENV['LIB_NAME'] = 'spree_alipay_forex_trade'
  Rake::Task['common:test_app'].invoke
end
