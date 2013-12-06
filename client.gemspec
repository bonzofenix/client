# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'client/version'

Gem::Specification.new do |spec|
  spec.name          = "client"
  spec.version       = Client::VERSION
  spec.authors       = ["bonzofenix"]
  spec.email         = ["bonzofenix@gmail.com"]
  spec.description   = %q{Client gives you the possibility to hit rest endpoints in an elegant way}
  spec.summary       = %q{solves rest comunications}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty"
  spec.add_dependency 'recursive-open-struct'
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
end
