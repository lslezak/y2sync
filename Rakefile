# require 'simplecov' if ENV['COVERAGE']

require "bundler"
require "bundler/gem_tasks"

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn "Run `bundle install` to install missing gems"
  exit e.status_code
end

require "rake"
require "yard"
require "rubocop/rake_task"

RuboCop::RakeTask.new
YARD::Rake::YardocTask.new
