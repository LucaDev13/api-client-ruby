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
      attr_accessor :url

      def initialize message, url
        super message

        @url = url
      end
    end
  end
end
