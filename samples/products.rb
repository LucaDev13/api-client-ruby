# encoding: utf-8
require 'invisiblehand'

api = InvisibleHand::API.new :app_id => "", :api_key => "", :region => "uk"

begin
  response = api.products(:query => "nickelback", :size => 5)

  response["results"].each do |product|
    puts "Title: %s" % product["best_page"]["title"]
    puts "Price: £%.2f" % product["best_page"]["price"]
    puts
  end
rescue InvisibleHand::Error::APIError => e
  puts "Oh noes! There was an error: #{e.message}"
end
