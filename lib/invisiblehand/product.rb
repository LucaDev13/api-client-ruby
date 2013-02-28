module InvisibleHand
  class Product
    # Array of fields that exist on a product returned from the InvisibleHand
    # API.
    FIELDS = [
      :pages,
      :ebay_pages,
      :best_page,
      :id,
      :title,
      :resource,
      :upcs,
      :eans,
      :mpns,
      :isbns,
      :asins,
      :brands,
      :models,
      :categories,
      :image_url,
      :number_of_pages,
    ]

    attr_accessor(*FIELDS)

    def initialize raw, api
      @api = api
      @raw = raw
      FIELDS.each { |key| self.send("#{key}=", @raw[key.to_s]) }

      if @raw["pages"]
        self.pages = @raw["pages"].map { |json| Page.new(json, @api) }
      end

      if @raw["ebay_pages"]
        self.ebay_pages = @raw["ebay_pages"].map { |json| Page.new(json, @api) }
      end

      if @raw["best_page"]
        self.best_page = Page.new(@raw["best_page"], @api)
      end
    end
  end
end
