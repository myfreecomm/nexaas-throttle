require "base64"

module Nexaas
  module Throttle
    class Controller
      def initialize(request)
        @request = request
      end

      def evaluate!(request_identifier)
        return if assets? || !api?
        request_identifier.new(@request).token
      end

      private

      def assets?
        @request.path.start_with?("/assets")
      end

      def api?
        content_type = (@request.media_type || @request.env["Content-Type"]).to_s
        %W(application/json application/xml).include?(content_type)
      end
    end
  end
end
