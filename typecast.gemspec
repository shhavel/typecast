# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'type_cast/version'

Gem::Specification.new do |spec|
  spec.name          = "typecast"
  spec.version       = TypeCast::VERSION
  spec.authors       = ["Alex Avoyants"]
  spec.email         = ["shhavel@gmail.com"]
  spec.summary       = %q{Type casting of attributes defined in superclass or realized through method_missing.}
  spec.description   = %q{Type casting of attributes defined in superclass or realized through method_missing. Works only for string attributes.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
