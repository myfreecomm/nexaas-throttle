require "redis-activesupport"
require "rack/attack"

module Rack
  class Attack
    def self.configuration
      @configuration ||= Nexaas::Throttle.configuration
    end

    def self.guardian(request)
      Nexaas::Throttle::Guardian.new(request, configuration)
    end

    def self.throttled?(req)
      throttled = throttles.any? do |name, throttle|
        throttle[req]
      end

      throttled && configuration.throttleable?
    end

    self.cache.store = ActiveSupport::Cache::RedisStore.new(configuration.redis_options)
    self.throttled_response = lambda do |env|
      headers = {
        "Content-Type" => (env["CONTENT_TYPE"] || env["Content-Type"]).to_s,
        "Retry-After" => (env["rack.attack.match_data"] || {})[:period].to_s
      }

      [429, headers, ["Retry later\n"]]
    end

    throttle("nexaas/throttle", limit: configuration.limit, period: configuration.period) do |request|
      guardian(request).throttle!
    end

    track("nexaas/track") do |request|
      guardian(request).track! if configuration.trackable?
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
        headers.merge!(rate_limit_headers(env)) if rate_limit_available?(env)
        [status, headers, body]
      end

      private

      def rack_attack_key
        "rack.attack.throttle_data"
      end

      def rate_limit_available?(env)
        env.key?(rack_attack_key) && env[rack_attack_key].key?("nexaas/throttle")
      end

      def rate_limit_headers(env)
        data = limit_data(env)
        return {} if data[:period].nil?

        {
          "X-RateLimit-Limit" => limit(data),
          "X-RateLimit-Reset" => reset(data),
          "X-RateLimit-Remaining" => remaining(data)
        }
      end

      def limit_data(env)
        data = env["rack.attack.match_data"]
        data ||= (env["rack.attack.throttle_data"] || {})["nexaas/throttle"]
        data || {}
      end

      def limit(limit_data)
        limit_data[:limit].to_s
      end

      def reset(limit_data)
        now = Time.now.utc
        period = limit_data[:period]
        (now + (period - now.to_i % period)).iso8601.to_s
      end

      def remaining(limit_data)
        (limit_data[:limit].to_i - limit_data[:count].to_i).to_s
      end
    end
  end
end
