# encoding: utf-8
require 'invisiblehand'

api = InvisibleHand::API.new :app_id => "", :api_key => "", :region => "uk"

begin
  price = api.live_price "http://www.amazon.co.uk/Here-And-Now/dp/B0064Y9L9C"

  puts "£%.2f" % price
rescue InvisibleHand::Error::APIError => e
  puts "Oh noes! There was an error: #{e.message}"
end
