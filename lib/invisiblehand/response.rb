module InvisibleHand
  class Response
    include Enumerable

    # Array of fields that exist on a response returned from the InvisibleHand
    # API.
    FIELDS = [
      :info,
      :results,
    ]

    attr_accessor(*FIELDS)

    def initialize raw, api
      @api = api
      @raw = raw
      FIELDS.each { |key| self.send("#{key}=", @raw[key.to_s]) }

      if @raw["results"]
        self.results = @raw["results"].map { |json| Product.new(json, @api) }
      end
    end

    def each &block
      self.results.each(&block)
    end
  end
end
