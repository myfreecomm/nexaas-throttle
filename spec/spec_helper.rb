require "codeclimate-test-reporter"
require "simplecov"

CodeClimate::TestReporter.start
SimpleCov.start

ENV["RAILS_ENV"] ||= "test"

require "bundler/setup"
require "fakeredis/rspec"

require "rack/test"
require "rails"
require "action_controller/railtie"

require "rspec/rails"
require "support/throttle_config"
require "support/dummy_app"
