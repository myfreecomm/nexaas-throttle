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

    def self.guardian(request)
      Nexaas::Throttle::Guardian.new(request, configuration.request_identifier)
    end

    self.cache.store = ActiveSupport::Cache::RedisStore.new(configuration.redis_options)
    self.throttled_response = lambda do |env|
      [429, throttled_headers(env), ["Retry later\n"]]
    end

    throttle("nexaas/throttle", limit: configuration.limit, period: configuration.period) do |request|
      guardian(request).throttle! if configuration.throttleable?
    end

    track("nexaas/track") do |request|
      configuration.trackable? && guardian(request).track!
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
        headers.merge!(rate_limit_headers(env))
        [status, headers, body]
      end

      private

      def rate_limit_headers(env)
        _, headers, _  = Rack::Attack::RateLimit.new(@app, throttle: "nexaas/throttle").call(env)
        headers.merge(reset_header(env))
      end

      def reset_header(env)
        limit_data = limit_data(env)
        period = limit_data[:period]
        return {} if period.nil?
        now = Time.now.utc
        { "X-RateLimit-Reset" => (now + (period - now.to_i % period)).iso8601.to_s }
      end

      def limit_data(env)
        data = env["rack.attack.match_data"]
        data ||= (env["rack.attack.throttle_data"] || {})["nexaas/throttle"]
        data || {}
      end
    end
  end
end
