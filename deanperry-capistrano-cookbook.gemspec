# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/cookbook/version'

Gem::Specification.new do |spec|
  spec.name          = "deanperry-capistrano-cookbook"
  spec.version       = Capistrano::Cookbook::VERSION
  spec.authors       = ["Dean Perry"]
  spec.email         = ["dean@deanperry.net"]
  spec.summary       = %q{Selection of Capistrano 3 tasks to reduce boilerplate required when deploying Rails and Sinatra applications}
  spec.homepage      = "https://github.com/deanperry/deanperry-capistrano-cookbook"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'capistrano', '~>  3.2'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
