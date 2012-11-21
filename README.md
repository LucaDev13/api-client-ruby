# Invisible::Hand::Ruby

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'invisible-hand-ruby', :git => "git@github.com:forward/invisible-hand-ruby.git"

And then execute:

    $ bundle

## Usage

The first thing you must do in order to use this gem is create a configuration
that contains your app ID and app key. You can obtain these from the Invisible
Hand API website:
[https://developer.getinvisiblehand.com/](https://developer.getinvisiblehand.com/).

The sample configuration in this repository gives you a taste of what the config
should look like. The gem will look for the config in the following locations in
the following order:

    - The path or Hash sent to the constructor
    - An ENV variable called INVISIBLE\_HAND\_CONFIG
    - The current working directory at: ./invisible\_hand.yml

Some example usage:

``` ruby
# Assuming you used bundler to install the gem
require 'bundler'
Bundler.require

# Instantiate the API object using the default config location
# ./invisible_hand.yml
api = InvisibleHand::API.new

# Instantiate the API object with a hard coded, not-in-file config.
api = InvisibleHand::API.new :app_id => "id", :app_key => "key"

# Instantiate the API object from a path to a file.
api = InvisibleHand::API.new "path/to/invisible_hand.yml"

# Search for products that match the query "ipad"
api.products({
  :query => "ipad"
})
#=> A massive hash that you can find details of at:
#     https://developer.getinvisiblehand.com/documentation

# Do a live price search on a product (price comes back as the currency in the
URL you specify. On amazon.com you get dollars, amazon.co.uk you get pounds.)
api.live_search "http://www.amazon.com/gp/product/B005SUHRZS"
#=> 11.25

# Search for a specific product by its Invisible Hand ID
api.product "f619c3e117d50d1a2b10930e5b202336"
#=> A hash containing details of this item. More info at:
      https://developer.getinvisiblehand.com/documentation

```

## Debugging

The gem looks for a DEBUG environment variable. If DEBUG is set, debugging
information will be printed out to the screen. This includes URL information
every time an API call is made.
