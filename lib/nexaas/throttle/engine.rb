module Nexaas
  module Throttle
    class Engine < ::Rails::Engine
      initializer "nexaas.throttle.insert_middleware", before: "initialize_cache" do |app|
        require "nexaas/throttle/middleware"
        app.middleware.use Nexaas::Throttle::Middleware
      end
    end
  end
end
