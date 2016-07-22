require "nexaas/throttle/version"
require "nexaas/throttle/configuration"
require "nexaas/throttle/engine"
require "nexaas/throttle/controller"

module Nexaas
  module Throttle
    def self.configure
      yield(configuration) if block_given?
      configuration.check!
    end

    def self.configuration
      @configuration ||=  Configuration.new
    end
  end
end
