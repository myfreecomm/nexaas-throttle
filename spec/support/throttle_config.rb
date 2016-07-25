require "nexaas/throttle"

Nexaas::Throttle.configure do |config|
  config.period = 1.minute

  config.limit = 2

  config.request_identifier = Class.new do
    def initialize(request)
      @request = request
    end

    def token
      "42"
    end
  end

  config.redis_options = {
    host: "localhost",
    port: 6379
  }
end
