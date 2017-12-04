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
        return if ignore_user_agents? || assets? || token.blank?
        request.env["nexaas.token"] = token
        yield if block_given?
      end

      def assets?
        path = request.path
        path.match(%r{/assets}).present? || path.match(extensions_regexp).present?
      end

      def extensions_regexp
        @assets_extensions ||= begin
                                 extensions_group = %w(css js png jpg gif).join("|")
                                 /\.(#{extensions_group})(\?\S*)?$/
                               end
      end

      def ignore_user_agents?
        ignored_user_agents && !ignored_user_agents.map { |regexp| regexp.match(request.user_agent) }.compact.blank?
      end
    end
  end
end
