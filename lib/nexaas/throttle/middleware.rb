require "redis-activesupport"
require "rack/attack"
require "rack/attack/rate-limit"

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

    throttle("nexaas/throttle", limit: configuration.limit, period: configuration.period) do |request|
      controller = Nexaas::Throttle::Controller.new(request)
      controller.evaluate!(configuration.request_identifier)
    end
  end
end

module Nexaas
  module Throttle
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = Rack::Attack.new(@app).call(env)
        _, rate_limit_headers, _  = Rack::Attack::RateLimit.new(@app, throttle: "nexaas/throttle").call(env)
        [status, headers.merge(rate_limit_headers), body]
      end
    end
  end
end
