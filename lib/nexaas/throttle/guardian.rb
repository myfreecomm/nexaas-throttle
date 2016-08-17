require "base64"

module Nexaas
  module Throttle
    class Guardian
      def initialize(request, request_identifier)
        @request = request
        @token = request_identifier.new(request).token
      end

      def throttle!
        validate { token }
      end

      def track!
        validate { true }
      end

      private

      attr_reader :request, :token

      def validate(&block)
        return if assets? || !api? || token.blank?
        request.env["nexaas.token"] = token
        yield if block_given?
      end

      def assets?
        request.path.start_with?("/assets")
      end

      def api?
        content_type = (request.media_type || request.env["Content-Type"]).to_s
        %W(application/json application/xml).include?(content_type)
      end
    end
  end
end
