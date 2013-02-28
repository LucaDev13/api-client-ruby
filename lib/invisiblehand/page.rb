module InvisibleHand
  class Page
    # Array of fields that exist on a page returned from the InvisibleHand
    # API.
    FIELDS = [
      :title,
      :deeplink,
      :original_url,
      :price,
      :currency,
      :pnp,
      :image_url,
      :retailer_name,
      :price_confidence,
      :live_price_url,
      :ean,
      :upc,
      :brand,
      :model,
      :mpn,
      :isbn,
      :asin,
      :category,
    ]

    attr_accessor(*FIELDS)

    def initialize raw, api
      @api = api
      @raw = raw
      FIELDS.each { |key| self.send("#{key}=", @raw[key.to_s]) }
    end

    def live_price opts = {}
      @api.live_price(self.live_price_url, opts)
    end
  end
end
