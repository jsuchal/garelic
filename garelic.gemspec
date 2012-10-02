# -*- encoding: utf-8 -*-
require File.expand_path('../lib/garelic/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jan Suchal"]
  gem.email         = ["johno@jsmf.net"]
  gem.description   = %q{Google Analytics Reports as "New Relic"-like performance monitoring for your Rails app}
  gem.summary       = %q{}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "garelic"
  gem.require_paths = ["lib"]
  gem.version       = Garelic::VERSION
end
