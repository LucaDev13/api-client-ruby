module InvisibleHand
  module Logger
    def logger
      unless @logger
        @logger = ::Logger.new(STDOUT)
        if DEBUG
          @logger.level = ::Logger::DEBUG
        else
          @logger.level = ::Logger::FATAL
        end
      end

      @logger
    end
  end
end
