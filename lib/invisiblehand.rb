libdir = File.dirname(__FILE__)
$LOAD_PATH << libdir unless $LOAD_PATH.include? libdir

require "invisiblehand/version"
require "invisiblehand/logger"
require "invisiblehand/api"
require "invisiblehand/errors"

require 'cgi'
require 'rest_client'
require 'yaml'
require 'logger'
require 'json'

module InvisibleHand
  DEBUG = !!ENV['DEBUG']
end
