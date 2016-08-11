# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dogwatch/version'

Gem::Specification.new do |spec|
  spec.name          = 'dogwatch'
  spec.version       = DogWatch::VERSION
  spec.authors       = ['David Greene']
  spec.email         = ['David_Greene@rapid7.com']
  spec.summary       = DogWatch::SUMMARY
  spec.description   = DogWatch::DESCRIPTION
  spec.homepage      = 'https://github.com/rapid7/dogwatch'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2'

  spec.add_runtime_dependency 'dogapi', '~> 1.21'
  spec.add_runtime_dependency 'thor', '~> 0.19'
end
