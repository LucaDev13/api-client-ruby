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
    #   api = InvisibleHand::API.new :app_key => "...", :app_id => "..."
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
      if invalid_config? and !@config[:development]
        message = "Your config does not contain an app_id and app_key. " +
          "Both are required to make API calls."

        raise Error::InvalidConfig.new message, @config
      end

      @config[:protocol] = @config[:use_ssl] == false ? "http://" : "https://"
      @config[:version] ||= "1"
    end

    def products opts = {}
      response = api_call :get, "/products", opts

      if opts[:raw]
        response
      else
        Response.new(response, self)
      end
    end

    def product id, opts = {}
      response = api_call :get, "/products/#{CGI.escape(id)}", opts

      if opts[:raw]
        response
      else
        Product.new(response, self)
      end
    end

    def page url, opts = {}
      response = api_call :get, "/pages/?url=#{CGI.escape(url)}", opts

      if opts[:raw]
        response
      else
        Page.new(response, self)
      end
    end

    def live_price url, opts = {}
      if url =~ /http:\/\/api\.invisiblehand/
        url += url_params_from opts
        json = api_raw_request :get, url
        json["price"]
      else
        opts[:url] = url
        json = api_call :get, "/pages/live_price", opts
        json["price"]
      end
    end

    def api_call method, path, opts = {}
      if !@config[:development]
        opts.merge!({
          :app_id => @config[:app_id],
          :app_key => @config[:app_key],
        })
      end

      query = url_params_from opts
      url   = "#{@config[:protocol]}#{endpoint}/v#{@config[:version]}#{path}?#{query}"

      if opts[:debug]
        debug { api_raw_request method, url }
      else
        api_raw_request method, url
      end
    end

    private

    # Gets the endpoint of the API to hit. Prioritises the :region config
    # parameter over :endpoint. In the event that neither are presents, defaults
    # to the US.
    def endpoint
      if @config[:region]
        "#{@config[:region]}.api.invisiblehand.co.uk"
      elsif @config[:endpoint]
        @config[:endpoint]
      else
        "us.api.invisiblehand.co.uk"
      end
    end

    def debug &block
      old_log_level = logger.level
      logger.level  = ::Logger::DEBUG
      result        = block.call
      result
    ensure
      logger.level  = old_log_level
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
        next if [:debug, :raw].include? key.to_sym

        "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
      end

      params.compact.join('&')
    end

    def invalid_config?
      (@config[:app_id].nil? or @config[:app_key].nil?)
    end
  end
end
