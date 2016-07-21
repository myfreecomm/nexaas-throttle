require "base64"

module Nexaas
  module Throttle
    class Controller
      def initialize(request)
        @request = request
      end

      def evaluate!(session_identifier)
        return if assets? || !api?
        session_identifier.new(@request).token
      end

      private

      def assets?
        @request.path.start_with?("/assets")
      end

      def api?
        %W(application/json application/xml).include?(@request.media_type.to_s)
      end
    end
  end
end
