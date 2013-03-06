# InvisibleHand API Client Ruby

A Ruby client library to the InvisibleHand API. Allows for very easy
programmatic access to the InvisibleHand API from Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'invisiblehand'

And then execute:

    $ bundle

Alternately you can just install directly through the `gem` command:

    $ gem install invisiblehand

## Usage

The first thing you must do in order to use this gem is create a configuration
that contains your app ID and app key. You can obtain these from the Invisible
Hand API website:
[https://developer.getinvisiblehand.com/](https://developer.getinvisiblehand.com/).

The sample configuration in this repository gives you a taste of what the config
should look like. The gem will look for the config in the following locations in
the following order:

    - The path or Hash sent to the constructor
    - An ENV variable called INVISIBLEHAND_CONFIG
    - The current working directory at: ./invisiblehand.yml

Some example usage:

``` ruby
require 'invisiblehand'

# Instantiate the API object using the default config location
# ./invisiblehand.yml
api = InvisibleHand::API.new

# Instantiate the API object with a hard coded, not-in-file config.
api = InvisibleHand::API.new :app_id => "id", :app_key => "key"

# Instantiate the API object from a path to a file.
api = InvisibleHand::API.new "path/to/invisiblehand.yml"

# Search for products that match the query "ipad"
api.products({
  :query => "ipad"
})
#=> An InvisibleHand::Response object that contains the methods #results and
#   #info. #results is an array of InvisibleHand::Product objects and #info is
#   a Hash of meta information on the request (number of results, etc.)

# Search for products with sorting and ordering and a specific size.
api.products({
  :query => "galaxy",    # Search term
  :sort => "popularity", # What to order results by
  :order => "desc",      # Direction to order results by
  :size => "100"         # Number of results to return
})

# Do a live price search on a product (price comes back in the currency for the
# region of the URL you specify, so for example, on amazon.com you get dollars and on
# amazon.co.uk you get pounds.)
api.live_price "http://www.amazon.com/gp/product/B005SUHRZS"
#=> 11.25

# You can also specify an InvisibleHand API link to the live_price method and
# it will work fine.
api.live_price "http://api.invisiblehand.co.uk/v1/pages/live_price?url=http%3A%2F%2Fwww.amazon.com%2Fgp%2Fproduct%2FB007PRHNHO"

# Search for a specific product by its InvisibleHand ID
api.product "f619c3e117d50d1a2b10930e5b202336"
#=> An InvisibleHand::Product object.

```

### Region

A little clarification surrounding what the `:region` parameter is for in the
`invisiblehand.sample.yml` file.

Because product data differs depending on where that product is being sold (for
example, `amazon.com` and `amazon.co.uk` differ in currency, price and so on), the
API returns only the data relevant to the region that you specify.

A product that exists in our dataset and has only pages in the UK will not be
returned for queries that are done on the US API endpoint.

### Errors

If the API returns any error information, an `InvisibleHand::Error::APIError` is
thrown and the `#message` method of the error object will contain the error
output from the API.

The `InvisibleHand::Error::APIError` object also contains `#url` and
`#raw_response` methods that give you what URL on the API got hit and what the
raw response from the server was for debugging purposes.

### Logging

The InvisibleHand gem does have debug logging that goes to an internal `Logger`
object. It should not output anything higher than the debug level, which it does
when the `DEBUG` environment variable is set.

If you wish to override the default logging object it builds internally, which
outputs to STDOUT, you can do so with the following code:

``` ruby
require 'invisiblehand'

# Ignore all InvisibleHand logging.
InvisibleHand.logger = Logger.new('/dev/null')
```

## Debugging

The gem looks for a DEBUG environment variable. If DEBUG is set, debugging
information will be printed out to the screen. This includes URL information
every time an API call is made.

Alternately, if you want to do ad-hoc debugging on single API calls you can pass
in a debugging option:

``` ruby
require 'invisiblehand'

api = InvisibleHand::API.new :app_id => "id", :app_key => "key"

api.products query: "nickelback", debug: true
#=> Result is the same as normal, you'll just get verbose debugging output to
#   the gem's internal logger (which you can override, see Logging above).
```

## Development

To run tests, first you will need a valid `invisiblehand.yml` config file inside
the `spec/` directory. The config you specify must be able to make API calls.

Once you have confirmed this, you can run tests with the following command:

    $ rake

And if you wish to see debugging information:

    $ DEBUG=true rake

## Contributing

If you have added a feature or fixed a bug and want to share it, please submit
a pull request as follows:

- Fork the project
- Write the code for your feature or bug fix
- Add tests - this is important to ensure the code you've added continues to work correctly
- Make sure the existing tests all pass
- Commit - do not mess with version, or history
- Submit a pull request
