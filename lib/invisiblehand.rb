libdir = File.dirname(__FILE__)
$LOAD_PATH << libdir unless $LOAD_PATH.include? libdir

require 'cgi'
require 'yaml'
require 'logger'
require 'rest_client'
require 'json'
require 'benchmark'

# Requires all .rb file in a given directory.
def require_all path
  Dir[File.join(File.dirname(__FILE__), path, '*.rb')].each { |f| require f }
end

# Logger is required early because it's a dependency of other classes.
require 'invisiblehand/logger'

require_all 'invisiblehand'

module InvisibleHand
  DEBUG = !!ENV['DEBUG']
end
