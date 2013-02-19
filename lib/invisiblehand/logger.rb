module InvisibleHand
  def self.logger
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

  # Override the InvisibleHand logger if you wish to have finer grained control
  # over where your application's output is going.
  #
  #   InvisibleHand.logger = Logger.new('my/app/logs.log')
  def self.logger= new_logger
    @logger = new_logger
  end

  # Helper module for classes to include if they want to use the main
  # InvisibleHand logger. Should be used for all in-gem logging as it is
  # configurable by the end-user of the gem.
  module Logger
    def logger
      InvisibleHand.logger
    end
  end
end
