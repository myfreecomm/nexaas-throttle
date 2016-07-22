require "codeclimate-test-reporter"
require "simplecov"

CodeClimate::TestReporter.start
SimpleCov.start

require "bundler/setup"
require "rails"
require "nexaas/throttle"

Nexaas::Throttle.configure do |config|
  config.period = 1.minute

  config.limit = 2

  config.session_identifier = Class.new do
    def initialize(request)
      @request = request
    end

    def token
      @request.token
    end
  end

  config.redis_options = {
    host: "localhost",
    port: 6379
  }
end


class DummyApp < Rails::Application
  config.eager_load = false
  config.active_support.test_order = :sorted
end

Rails.application.initialize!
