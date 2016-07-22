module Nexaas
  module Throttle
    class Engine < ::Rails::Engine
      initializer "nexaas.throttle.insert_middleware", before: "initialize_cache" do |app|
        require "nexaas/throttle/middleware"
        require "rack/attack/rate-limit"
        app.middleware.use Nexaas::Throttle::Middleware
        app.middleware.use Rack::Attack::RateLimit, throttle: "nexass/throttle"
      end
    end
  end
end
