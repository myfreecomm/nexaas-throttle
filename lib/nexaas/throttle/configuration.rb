module Nexaas
  module Throttle
    class Configuration
      attr_accessor :period, :limit, :session_identifier, :redis_options
    end
  end
end
