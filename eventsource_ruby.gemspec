# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eventsource_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = "eventsource_ruby"
  spec.version       = EventsourceRuby::VERSION
  spec.authors       = ["Tom Meinlschmidt"]
  spec.email         = ["tomas@meinlschmidt.com"]
  spec.summary       = spec.description = %q{Server-sent Event (SSE) ruby server}
  spec.homepage      = "https://tom.meinlschmidt.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'celluloid', '>= 0.16.0'
  spec.add_dependency 'json'
  spec.add_dependency 'http_parser.rb'
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
