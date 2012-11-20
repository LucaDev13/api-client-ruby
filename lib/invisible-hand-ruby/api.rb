module InvisibleHand
  class API
    include Logger
    attr_accessor :config
    PROTOCOL = "https://"

    def initialize conf = nil
      if conf.is_a? Hash
        @config = config
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
      api_call :get, "/v1/pages/live_price", opts
    end

    def api_call method, path, opts = {}
      opts.merge! @config
      region = opts.delete :region
      base_url = "#{region}.api.invisiblehand.co.uk"

      query = opts.map do |key, value|
        "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
      end.join("&")

      url = "#{PROTOCOL}#{base_url}#{path}?#{query}"
      logger.debug "API call URL: #{url}"

      response = RestClient.send(method, url)
      JSON.parse(response.body)
    end
  end
end
