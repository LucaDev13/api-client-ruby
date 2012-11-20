libdir = File.dirname(__FILE__)
$LOAD_PATH << libdir unless $LOAD_PATH.include? libdir

require "invisible-hand-ruby/version"
require "invisible-hand-ruby/logger"
require "invisible-hand-ruby/api"

require 'cgi'
require 'rest_client'
require 'yaml'
require 'logger'
require 'json'

module InvisibleHand
  DEBUG = !!ENV['DEBUG']
end
