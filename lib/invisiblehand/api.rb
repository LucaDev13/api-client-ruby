module InvisibleHand
  class API
    include InvisibleHand::Logger
    attr_accessor :config

    # When initializing a new instance of `InvisibleHand::API`, you can specify
    # configuration in one of three ways:
    #
    #   require 'invisiblehand'
    #
    #   # This looks first for an environment variable called
    #   # "INVISIBLEHAND_CONFIG", which should contain a file path to a config
    #   # YAML file. Failing that, "./invisiblehand.yml" is used, looking for
    #   # the config YAML file in the current directory.
    #   api = InvisibleHand::API.new
    #
    #   # This one takes a string argument which should be a valid file path to
    #   # the YAML config file.
    #   api = InvisibleHand::API.new "path/to/invisiblehand.yml"
    #
    #   # Or you can do a literal hash config. This requires no YAML config
    #   # file.
    #   api = InvisibleHand::API.new :api_key => "...", :app_id => "..."
    #
    # Examples of the configuration variables you can pass in can be found in
    # the "invisiblehand.sample.yml" file in this gem's GitHub repository.
    def initialize conf = nil
      if conf.is_a? Hash
        @config = conf
      elsif conf.is_a? String
        @config = YAML.load_file(conf)
      else
        conf ||= ENV['INVISIBLEHAND_CONFIG'] || './invisiblehand.yml'
        @config = YAML.load_file(conf)
      end

      # The @config[:development] flag exists to bypass the app_id and app_key
      # check in this gem (not on the server) for internal testing reasons.
      if valid_config?
        message = "Your config does not contain an app_id and app_key. " +
          "Both are required to make API calls."

        raise Error::InvalidConfig.new message, @config
      end

      @config[:protocol] = @config[:use_ssl] == false ? "http://" : "https://"
      @config[:endpoint] ||= "us.api.invisiblehand.co.uk"
    end

    def products opts = {}
      api_call :get, "/v1/products", opts
    end

    def product id, opts = {}
      api_call :get, "/v1/products/#{CGI.escape(id)}", opts
    end

    def live_price url, opts = {}
      if url =~ /http:\/\/api\.invisiblehand/
        url += url_params_from opts
        json = api_raw_request :get, url
        json["price"]
      else
        opts[:url] = url
        json = api_call :get, "/v1/pages/live_price", opts
        json["price"]
      end
    end

    def api_call method, path, opts = {}
      query = url_params_from opts
      url   = "#{@config[:protocol]}#{@config[:endpoint]}#{path}?#{query}"

      if opts[:debug]
        debug { api_raw_request method, url }
      else
        api_raw_request method, url
      end
    end

    private

    def debug &block
      old_log_level = logger.level
      logger.level  = ::Logger::DEBUG
      result        = block.call
      logger.level  = old_log_level
      result
    end

    def api_raw_request method, url
      logger.debug "API call URL: #{url}"

      # Declare these early to avoid scoping programs in the timing block.
      response = nil
      json     = nil

      elapsed = Benchmark.realtime do
        response = RestClient.send(method, url) { |resp, req, res| resp }
        json     = JSON.parse(response.body)
      end

      logger.debug "API call took #{elapsed.round(3)} seconds."
      logger.debug "API json response: #{json.inspect}"

      raise Error::APIError.new(json["error"], url, response) if json["error"]

      json
    end

    def url_params_from hash
      params = hash.map do |key, value|
        # There are some parameters that will be passed to an API call that we
        # don't want to include in the query string. Filter them out here.
        next if [:debug].include? key.to_sym

        "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
      end

      params.compact.join('&')
    end

    def valid_config?
      @config[:app_id].nil? and
        @config[:app_key].nil? and
        !@config[:development]
    end
  end
end
