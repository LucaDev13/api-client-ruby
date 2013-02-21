module InvisibleHand
  module Error
    class InvalidConfig < StandardError
      attr_accessor :config

      def initialize message, config
        super message

        @config = config
      end
    end

    class APIError < StandardError
      attr_accessor :url, :raw_response

      def initialize message, url, raw_response
        super message

        @url          = url
        @raw_response = raw_response
      end
    end
  end
end
