require "nexaas/throttle/version"
require "nexaas/throttle/configuration"
require "nexaas/throttle/engine"
require "nexaas/throttle/controller"

module Nexaas
  module Throttle
    def self.configuration
      @configuration ||=  Configuration.new
    end

    def self.configure
      yield(configuration) if block_given?
    end

    def self.control!(request)
      controller = Controller.new(request)
      controller.evaluate!(configuration.session_identifier)
    end
  end
end
