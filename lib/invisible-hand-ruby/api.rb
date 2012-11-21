module InvisibleHand
  class API
    include Logger
    attr_accessor :config
    PROTOCOL = "https://"
    VALID_REGIONS = [
      "uk", "us", "de", "ca"
    ]

    def initialize conf = nil
      if conf.is_a? Hash
        @config = conf
      elsif conf.is_a? String
        @config = YAML.load_file(conf)
      else
        conf ||= ENV['INVISIBLE_HAND_CONFIG']
        @config = YAML.load_file(conf || './invisible_hand.yml')
      end

      if @config[:app_id].nil? and @config[:app_key].nil?
        throw "Your config does not contain an app_id and app_key." +
              "Both are required to make API calls."
      end
    end

    def products opts = {}
      api_call :get, "/v1/products", opts
    end

    def product id, opts = {}
      api_call :get, "/v1/products/#{CGI.escape(id)}", opts
    end

    def live_price url, opts = {}
      if url =~ /http:\/\/api\.invisiblehand/
        # Don't need the region to be in there
        opts.delete :region

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
      opts = @config.merge opts
      region = opts.delete(:region) || "us"

      unless VALID_REGIONS.include? region
        raise Error::InvalidConfig.new "Region #{region} is not a valid " +
          "region. Choose one of the following: #{VALID_REGIONS.join(', ')}"
      end

      base_url = "#{region.downcase}.api.invisiblehand.co.uk"
      query    = url_params_from opts
      url      = "#{PROTOCOL}#{base_url}#{path}?#{query}"

      api_raw_request method, url
    end

    private

    def api_raw_request method, url
      logger.debug "API call URL: #{url}"

      response = RestClient.send(method, url) { |resp, req, res| resp }
      json     = JSON.parse(response.body)

      if json["error"]
        raise Error::APIError.new json["error"]
      end

      json
    end

    def url_params_from hash
      hash.map do |key, value|
        "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
      end.join("&")
    end
  end
end
