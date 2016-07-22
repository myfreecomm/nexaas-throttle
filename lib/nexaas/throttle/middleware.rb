require "rack/attack"
require "redis-activesupport"

module Rack
  class Attack
    def self.configuration
      @configuration ||= Nexaas::Throttle.configuration
    end

    def self.throttled_headers(env)
      content_type = env["CONTENT_TYPE"]
      retry_after = (env["rack.attack.match_data"] || {})[:period]

      {
        "Content-Type" => content_type,
        "Retry-After" => retry_after.to_s
      }
    end

    self.cache.store = ActiveSupport::Cache::RedisStore.new(configuration.redis_options)
    self.throttled_response = lambda do |env|
      [429, throttled_headers(env), ["Retry later\n"]]
    end

    throttle("nexass/throttle", limit: configuration.limit, period: configuration.period) do |request|
      controller = Nexaas::Throttle::Controller.new(request)
      controller.evaluate!(configuration.session_identifier)
    end
  end
end

module Nexaas
  module Throttle
    Middleware = ::Rack::Attack
  end
end
