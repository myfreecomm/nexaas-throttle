module Nexaas
  module Throttle
    class Configuration
      # The size of the throttle window.
      # Example: 1.minute, 1.hour, 60(s)
      # @return [Integer]
      attr_accessor :period

      # How many requests a consumer can do during a window until he starts being throttled.
      # Example: 60
      # @return [Integer]
      attr_accessor :limit

      # The class that will handle session identification.
      # Each application handle with different domains on identifying a request,
      # so they have to provide information on who is the requester based on their domain.
      # This class MUST have the following interface:
      # MySessionIdentifier#initialize(request)
      # MySessionIdentifier#token
      # Where MySessionIdentifier#token must be a UNIQUE identifier from the requester.
      # @return [Class]
      attr_accessor :session_identifier

      # Redis hash configuration with the following default values:
      #   - host      => localhost
      #   - port      => 6379
      #   - db        => 0
      #   - namespace => nexaas:throttle
      # @return [Hash]
      attr_reader :redis_options

      def initialize
        @period = 1.minute
        @limit = 60
        @session_identifier = nil
        @redis_options = default_redis_options
      end

      def check!
        instance_variables.each do |ivar|
          raise ArgumentError, "You must provide a `#{ivar}` configuration." if instance_variable_get(ivar).blank?
        end
      end

      def redis_options=(options)
        @redis_options = default_redis_options.merge(options)
      end

      private

      def default_redis_options
        {
          host: "localhost",
          port: 6379,
          db: 0,
          namespace: "nexaas:throttle"
        }
      end
    end
  end
end
