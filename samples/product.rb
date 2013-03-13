# encoding: utf-8
require 'invisiblehand'

api = InvisibleHand::API.new :app_id => "", :app_key => "", :region => "uk"

begin
  # The "78b4fb8fa97b8bc746726a32d3393833" bit is a product ID in our database.
  # You aren't expected to know these beforehand, they will come from other API
  # calls.
  product = api.product "78b4fb8fa97b8bc746726a32d3393833"

  product["pages"].each do |page|
    puts "Retailer: %s" % page["retailer_name"]
    puts "Title: %s" % page["title"]
    puts "Price: £%.2f" % page["price"]
    puts
  end
rescue InvisibleHand::Error::APIError => e
  puts "Oh noes! There was an error: #{e.message}"
end
