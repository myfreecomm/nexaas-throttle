require "base64"

module Nexaas
  module Throttle
    class Guardian
      def initialize(request, configuration)
        @request = request
        @token = configuration.request_identifier.new(request).token
        @ignored_user_agents = configuration.ignored_user_agents
      end

      def throttle!
        validate { token }
      end

      def track!
        validate { true }
      end

      private

      attr_reader :request, :token, :ignored_user_agents

      def validate
        return if ignore_user_agents? || assets? || !api? || token.blank?
        request.env["nexaas.token"] = token
        yield if block_given?
      end

      def assets?
        path = request.path
        path.match(/\/assets/).present? || path.match(extensions_regexp).present?
      end

      def api?
        content_type = (request.media_type || request.env["Content-Type"]).to_s
        %w(application/json application/xml).include?(content_type)
      end

      def extensions_regexp
        @assets_extensions ||= begin
          extensions = %w(css js png jpg gif)
          /\.(#{extensions.join("|")})/
        end
      end

      def ignore_user_agents?
        ignored_user_agents && ignored_user_agents.include?(request.user_agent)
      end
    end
  end
end
