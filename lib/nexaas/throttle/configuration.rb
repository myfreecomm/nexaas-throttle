module Nexaas
  module Throttle
    class Configuration
      # Whether or not requests are throttled.
      # @return [Boolean]
      attr_accessor :throttle

      # Whether or not requests are tracked.
      # @return [Boolean]
      attr_accessor :track

      # The size of the throttle window.
      # Example: 1.minute, 1.hour, 60(s)
      # @return [Integer]
      attr_accessor :period

      # How many requests a consumer can do during a window until he starts being throttled.
      # Example: 60
      # @return [Integer]
      attr_accessor :limit

      # The class that will handle request identification.
      # Each application handle with different domains on identifying a request,
      # so they have to provide information on who is the requester based on their domain.
      # This class MUST have the following interface:
      # MyRequestIdentifier#initialize(request)
      # MyRequestIdentifier#token
      # Where MyRequestIdentifier#token must be a UNIQUE identifier from the requester.
      # @return [Class]
      attr_accessor :request_identifier

      # Redis hash configuration with the following default values:
      #   - host      => localhost
      #   - port      => 6379
      #   - db        => 0
      #   - namespace => nexaas:throttle
      # @return [Hash]
      attr_reader :redis_options

      alias_method :throttleable?, :throttle
      alias_method :trackable?, :track

      def initialize
        @throttle = true
        @track = true
        @period = 1.minute
        @limit = 60
        @request_identifier = nil
        @redis_options = default_redis_options
      end

      def check!
        required_options.each do |option|
          raise ArgumentError, "You must provide a `#{option}` configuration." if send(option).blank?
        end
      end

      def redis_options=(options)
        options ||= {}
        @redis_options = default_redis_options.merge(options)
      end

      private

      def required_options
        %w(period limit request_identifier redis_options)
      end

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
