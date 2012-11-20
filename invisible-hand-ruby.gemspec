# -*- encoding: utf-8 -*-
require File.expand_path('../lib/invisible-hand-ruby/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Sam Rose"]
  gem.email         = ["sam.rose@forward.co.uk"]
  gem.description   = %q{Ruby API client library to the Invisible Hand API.}
  gem.summary       = %q{Allows for easy programmatic access to the Invisible Hand API.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "invisible-hand-ruby"
  gem.require_paths = ["lib"]
  gem.version       = InvisibleHand::VERSION

  # Dependencies
  gem.add_dependency("rest-client")
end
